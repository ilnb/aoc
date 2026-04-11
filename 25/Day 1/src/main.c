#include <assert.h>
#include <stdio.h>
#define N 4664

int main() {
  FILE *f = fopen("input", "r");
  int p1 = 0, p2 = 0;
  int dial = 50;
  for (int i = 0; i < N; ++i) {
    char c;
    int val;
    fscanf(f, "%c%d\n", &c, &val);
    if (val > 100)
      p2 += val / 100;
    val %= 100;
    int flag = dial && (c == 'L' && val > dial) || (c == 'R' && val > 100 - dial);
    p2 += flag;
    if (c == 'L')
      dial = (dial - val + 100) % 100;
    else if (c == 'R')
      dial = (dial + val) % 100;
    else
      assert(0 && "parsing issue\n");
    p1 += !dial;
    p2 -= flag && !dial;
  }
  p2 += p1;

  printf("p1: %d\np2: %d\n", p1, p2);
  return 0;
}
