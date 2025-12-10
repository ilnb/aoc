import re
import sys
from pathlib import Path
import pulp

# ---------- parsing helpers ----------
# Convert cfg like "[.##.]" -> mask (leftmost visible char = index 0)
def cfg_to_mask(s: str):
    if s.startswith("[") and s.endswith("]"):
        s = s[1:-1]
    mask = 0
    for i, ch in enumerate(s):
        if ch == '#':
            mask |= (1 << i)
    return mask

# Convert button text like "(0,3,5)" -> integer mask where bit k is set if k present
def btn_to_mask(s: str):
    if s.startswith("(") and s.endswith(")"):
        s = s[1:-1]
    s = s.strip()
    if s == "":
        return 0
    parts = [p.strip() for p in s.split(",") if p.strip() != ""]
    mask = 0
    for p in parts:
        idx = int(p)
        mask |= (1 << idx)
    return mask

# Parse a line format:
# <cfg> <btn1> <btn2> ... {j1,j2,...}
# Example:
# [ .##. ] (0,2) (1) {1,0,2}
line_re = re.compile(r"""
    ^\s*
    (?P<cfg>\[[^\]]*\])            # bracketed cfg
    \s+
    (?P<buttons>.*\{[^}]*\})       # everything until the final { ... }
    \s*$
""", re.VERBOSE)

# extract buttons (parenthesized) and final {j1,..}
btn_re = re.compile(r"\([^\)]*\)")
jolt_re = re.compile(r"\{([^\}]*)\}")

def parse_line(line: str):
    m = line_re.match(line)
    if not m:
        raise ValueError(f"line doesn't match expected format: {line!r}")
    cfg = m.group("cfg").strip()
    tail = m.group("buttons")
    # find all button groups
    buttons = btn_re.findall(tail)
    # find joltage list
    jb = jolt_re.search(tail)
    if not jb:
        raise ValueError(f"no joltages found in line: {line!r}")
    jolt_str = jb.group(1)
    # parse joltages as integers
    jolts = [int(x.strip()) for x in jolt_str.split(",") if x.strip() != ""]
    # parse each button into mask
    btn_masks = [btn_to_mask(b.strip()) for b in buttons]
    return cfg, btn_masks, jolts

# ---------- ILP solver for one machine ----------
def solve_machine_ilp(btn_masks, jolts, verbose=False):
    import pulp
    n_buttons = len(btn_masks)
    n_switches = len(jolts)

    # Build A matrix
    A = [[0 for _ in range(n_buttons)] for __ in range(n_switches)]
    for j, mask in enumerate(btn_masks):
        m = mask
        i = 0
        while m:
            if m & 1:
                if i < n_switches:
                    A[i][j] = 1
            m >>= 1
            i += 1

    # Setup ILP with integer non-negative variables (counts)
    prob = pulp.LpProblem("machine_min_button_counts", pulp.LpMinimize)
    # integer variables >= 0
    x = [pulp.LpVariable(f"x_{j}", lowBound=0, cat="Integer") for j in range(n_buttons)]

    # Objective: minimize total presses
    prob += pulp.lpSum(x[j] for j in range(n_buttons))

    # Equality constraints A x == b
    for i in range(n_switches):
        prob += (pulp.lpSum(A[i][j] * x[j] for j in range(n_buttons)) == jolts[i]), f"switch_{i}"

    # Solve
    solver = pulp.PULP_CBC_CMD(msg=0)  # msg=1 to see solver logs
    status = prob.solve(solver)
    status_str = pulp.LpStatus[prob.status]

    if status_str != "Optimal":
        if verbose:
            print("=== ILP debug ===")
            print("Status:", status_str)
            print("A matrix:")
            for row in A:
                print(row)
            print("b vector:", jolts)
            print("n_buttons:", n_buttons, "n_switches:", n_switches)
            # Print constraint feasibility in integer relaxation (quick check)
            try:
                sol_relaxed = prob.solve(pulp.PULP_CBC_CMD(msg=0, timeLimit=5))
            except Exception:
                pass
        return None

    val = sum(int(pulp.value(xj)) for xj in x)
    return val


# ---------- main ----------
def main(inp_path: str):
    total_p2 = 0
    with open(inp_path, "r", encoding="utf8") as f:
        for lineno, raw in enumerate(f, 1):
            line = raw.strip()
            if line == "":
                continue
            try:
                cfg, btn_masks, jolts = parse_line(line)
            except Exception as e:
                print(f"parse error line {lineno}: {e}", file=sys.stderr)
                continue

            # For debugging:
            # print("cfg:", cfg, "btns:", btn_masks, "jolts:", jolts)

            res = solve_machine_ilp(btn_masks, jolts)
            if res is None:
                print(f"Line {lineno}: infeasible ILP (no solution) for machine")
            else:
                print(f"Line {lineno}: min buttons = {res}")
                total_p2 += res

    print("TOTAL P2 =", total_p2)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("usage: solve_p2.py <input-file>")
        sys.exit(1)
    main(sys.argv[1])
