#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef uint64_t ull;
#define N 850
typedef unsigned char uc;

// bitmasked, handles all operators
uc check(int *, int, int, ull, ull);

#include <stdio.h>

int main() {
  FILE *f = fopen("input", "r");
  if (!f) {
    fprintf(stderr, "input file missing\n");
    return 1;
  }
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
    int j = 0;
    for (; j < n - 1; ++j)
      fscanf(f, "%d ", arr + j);
    fscanf(f, "%d\n", arr + j);
    uc bits = check(arr, n, 1, arr[0], t);
    if (bits & 1)
      p1 += t;
    if (bits & 2)
      p2 += t;
    free(arr);
  }
  printf("p1: %lu\np2: %lu\n", p1, p2);
  return 0;
}

uc check(int *arr, int n, int idx, ull v, ull t) {
  if (idx == n)
    return v == t ? 3 : 0;

  uc ret = 0;

  ull add = v + arr[idx];
  if (add <= t)
    ret |= check(arr, n, idx + 1, add, t);

  if (arr[idx] != 0 && v <= t / arr[idx]) {
    ull mul = v * arr[idx];
    if (mul <= t)
      ret |= check(arr, n, idx + 1, mul, t);
  }

  int tmp = arr[idx], p = 1;
  while (tmp > 0) {
    p *= 10;
    tmp /= 10;
  }
  v = v * p + arr[idx];
  if (v <= t)
    if (check(arr, n, idx + 1, v, t))
      ret |= 2;

  return ret;
}
