#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define N 850

typedef uint64_t ull;
typedef unsigned char uc;
uc check(int *, int, int, ull, ull);

int main() {
  FILE *f = fopen("input", "r");
  assert(f && "input file missing");
  ull p1 = 0, p2 = 0;
  for (int i = 0; i < N; ++i) {
    ull t;
    fscanf(f, "%lu:", &t);
    int offset = 0, n = 0;
    char c;
    while ((c = fgetc(f)) != '\n') {
      if (c == ' ')
        n++;
      offset++;
    }
    fseek(f, -offset, SEEK_CUR);
    int *arr = malloc(n * sizeof(int));
    for (int j = 0; j < n; ++j)
      fscanf(f, " %d", arr + j);
    uc bits = check(arr, n, 1, *arr, t);
    if (bits & 1)
      p1 += t;
    if (bits & 2)
      p2 += t;
    free(arr);
  }
  printf("p1: %lu\np2: %lu\n", p1, p2);
  fclose(f);
  return 0;
}

uc check(int *arr, int n, int idx, ull v, ull t) {
  if (idx == n)
    return v == t ? 3 : 0;

  uc ret = 0;

  ull add = v + arr[idx];
  if (add <= t)
    ret |= check(arr, n, idx + 1, add, t);

  if (v <= t / arr[idx])
    ret |= check(arr, n, idx + 1, v * arr[idx], t);

  int tmp = arr[idx], p = 1;
  while (tmp > 0) {
    p *= 10;
    tmp /= 10;
  }
  v = v * p + arr[idx];
  if (v <= t && check(arr, n, idx + 1, v, t))
    ret |= 2;

  return ret;
}
