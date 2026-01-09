#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

int unwrap(char *buf)
{
  int len = 0;
  while (*buf)
    len += *buf++ - '0';
  return len;
}

#define N 20000

int main()
{
  char buf[N];
  FILE *f = fopen("input", "r");
  fscanf(f, "%s\n", buf);
  int n = unwrap(buf);
  int *arr = malloc(sizeof(int) * n);

  int id = 0, j = 0;
  for (int i = 0; i < N - 1; ++i) {
    int l = buf[i] - '0';
    if (i & 1) {
      for (int k = j; k < j + l; ++k)
        arr[k] = -1;
    } else {
      for (int k = j; k < j + l; ++k)
        arr[k] = id;
      id++;
    }
    j += l;
  }

  uint64_t p1 = 0;
  int l = 0, r = n - 1;
  while (l < r) {
    while (l < r && arr[l] != -1)
      p1 += arr[l] * l, l++;
    while (r > l && arr[r] == -1)
      r--;
    if (l < r)
      p1 += (l++) * arr[r--];
  }
  if (l == r && arr[l] != -1)
    p1 += arr[l] * l;
  printf("p1: %zu\n", p1);

  uint64_t p2 = 0;
  for (int t = id - 1; t >= 0; --t) {
    int l = -1, r = -1;
    for (int i = 0; i < j; ++i) {
      if (arr[i] == t) {
        if (l == -1)
          l = i;
        r = i;
      }
    }

    int len = r - l + 1;
    int best = -1;
    int idx = -1, space = 0;

    for (int i = 0; i < l; ++i) {
      if (arr[i] == -1) {
        if (space == 0)
          idx = i;
        space++;
      } else {
        if (space >= len) {
          if (best == -1 || idx < best)
            best = idx;
        }
        space = 0;
      }
    }
    if (space >= len) {
      if (best == -1 || idx < best)
        best = idx;
    }

    if (best != -1) {
      for (int i = 0; i < len; ++i)
        arr[best + i] = t;
      for (int i = l; i <= r; ++i)
        arr[i] = -1;
    }
  }
  for (int i = 0; i < j; ++i) {
    if (arr[i] != -1)
      p2 += (uint64_t)i * arr[i];
  }
  printf("p2: %lu\n", p2);

  fclose(f);
  free(arr);
  return 0;
}
