#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct pair {
  int x, y;
} pair;

static const int drow[4] = {-1, 0, 1, 0};
static const int dcol[4] = {0, 1, 0, -1};

#define LEN 130
#define valid(r, c) (r >= 0 && r < LEN && c >= 0 && c < LEN)

static bool cand[LEN][LEN];
static int stamp[LEN][LEN][4];

int move1(int orow, int ocol, char **grid) {
  int row = orow, col = ocol, steps = 0;
  for (int dir = 0;; dir = (dir + 1) & 3) {
    while (valid(row, col) && grid[row][col] != '#') {
      if (grid[row][col] != 'X') {
        grid[row][col] = 'X';
        steps++;
        cand[row][col] = true;
      }
      row += drow[dir];
      col += dcol[dir];
    }
    if (!valid(row, col))
      return steps;
    row -= drow[dir];
    col -= dcol[dir];
  }
}

static int epoch;
bool loops(int orow, int ocol, char **grid) {
  epoch++;
  int row = orow, col = ocol;
  for (int dir = 0;; dir = (dir + 1) & 3) {
    while (valid(row, col) && grid[row][col] != '#') {
      if (stamp[row][col][dir] == epoch)
        return true;
      stamp[row][col][dir] = epoch;
      row += drow[dir];
      col += dcol[dir];
    }
    if (!valid(row, col))
      return false;
    row -= drow[dir];
    col -= dcol[dir];
  }
}

int move2(int orow, int ocol, char **grid) {
  int obs = 0;
  for (int r = 0; r < LEN; r++) {
    for (int c = 0; c < LEN; c++) {
      if (!cand[r][c] || (r == orow && c == ocol))
        continue;
      char save = grid[r][c];
      grid[r][c] = '#';
      obs += loops(orow, ocol, grid);
      grid[r][c] = save;
    }
  }
  return obs;
}

int main() {
  FILE *f = fopen("input", "r");
  assert(f && "input file missing");
  if (!f) {
    printf("Trouble opening the file.\n");
    exit(1);
  }
  char buf[LEN][LEN + 1] = {};
  char *grid[LEN];
  for (int j = 0; j < LEN; j++) {
    fscanf(f, "%s\n", buf[j]);
    grid[j] = buf[j];
  }
  fclose(f);
  int row, col;
  for (int j = 0; j < LEN; j++) {
    int i;
    for (i = 0; i < LEN && grid[j][i] != '^'; i++)
      if (grid[j][i] == '^') {
      }
    if (i != LEN) {
      row = j, col = i;
      break;
    }
  }
  printf("steps: %d\nobs: %d\n", move1(row, col, grid), move2(row, col, grid));
  return 0;
}
