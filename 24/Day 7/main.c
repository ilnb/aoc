#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define N 850

typedef uint64_t u64;
typedef uint8_t u8;
u8 check(int *, int, int, u64, u64);

int main() {
  FILE *f = fopen("input", "r");
  assert(f && "input file missing");
  u64 p1 = 0, p2 = 0;
  for (int i = 0; i < N; ++i) {
    u64 t;
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
    u8 bits = check(arr, n, 1, *arr, t);
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

u8 check(int *arr, int n, int idx, u64 v, u64 t) {
  if (idx == n)
    return v == t ? 3 : 0;

  u8 ret = 0;

  u64 add = v + arr[idx];
  if (add <= t)
    ret |= check(arr, n, idx + 1, add, t);

  if (v <= t / arr[idx])
    ret |= check(arr, n, idx + 1, v * arr[idx], t);

  int p = 1;
  for (int tmp = arr[idx]; tmp; tmp /= 10)
    p *= 10;
  v = v * p + arr[idx];
  if (v <= t && check(arr, n, idx + 1, v, t))
    ret |= 2;

  return ret;
}
