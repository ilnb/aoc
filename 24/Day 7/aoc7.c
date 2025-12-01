#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef uint64_t ull;
#define N 850

// handles +, *
int check(int *, int, int, uint64_t, ull);
// check() with || operator
int check2(int *, int, int, uint64_t, ull);

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
    if (check(arr, n, 1, arr[0], t))
      p1 += t;
    if (check2(arr, n, 1, arr[0], t))
      p2 += t;
    free(arr);
  }
  printf("p1: %lu\np2: %lu\n", p1, p2);
  return 0;
}

int check(int *arr, int n, int idx, ull v, ull t) {
  if (idx == n)
    return v == t;
  ull add = v + arr[idx];
  if (add <= t && check(arr, n, idx + 1, add, t))
    return 1;
  if (v <= t / arr[idx]) {
    ull mul = v * arr[idx];
    if (mul <= t && check(arr, n, idx + 1, mul, t))
      return 1;
  }
  return 0;
}

int check2(int *arr, int n, int idx, ull v, ull t) {
  if (idx == n)
    return v == t;
  ull add = v + arr[idx];
  if (add <= t && check2(arr, n, idx + 1, add, t))
    return 1;
  if (v <= t / arr[idx]) {
    ull mul = v * arr[idx];
    if (mul <= t && check2(arr, n, idx + 1, mul, t))
      return 1;
  }
  int tmp = arr[idx], p = 1;
  while (tmp > 0) {
    p *= 10;
    tmp /= 10;
  }
  v = v * p + arr[idx];
  return check2(arr, n, idx + 1, v, t);
}
