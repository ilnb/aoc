#include "dyn_arr.h"
#include <assert.h>
#include <stdio.h>

typedef struct pair {
  int x, y;
} pair;

DEF_DA(da, pair);

#define N 50

#define is_d(c) (c >= '0' && c <= '9')

#define is_a(c) (c >= 'a' && c <= 'z')

#define is_A(c) (c >= 'A' && c <= 'Z')

#define valid_idx(nx, ny) (nx >= 0 && nx < N && ny >= 0 && ny < N)

int **mat(int m, int n) {
  void **p = malloc(sizeof(int *) * m);
  char *d = calloc(m * n, sizeof(int));
  for (int i = 0; i < m; i++)
    p[i] = d + i * n * sizeof(int);
  return (int **)p;
}

int gcd(int a, int b) {
  while (b) {
    int t = b;
    b = a % b;
    a = t;
  }
  return a;
}

void get_antinodes(da *, int **);
void get_antinodes2(da *, int **);

int main() {
  FILE *f = fopen("input", "r");
  da d_arr[10], a_arr[26], A_arr[26];
  for (int i = 0; i < 26; ++i)
    da_init(a_arr + i);
  for (int i = 0; i < 26; ++i)
    da_init(A_arr + i);
  for (int i = 0; i < 10; ++i)
    da_init(d_arr + i);
  for (int i = 0; i < N; ++i) {
    char buf[N + 1];
    fscanf(f, "%s\n", buf);
    for (int j = 0; j < N; ++j) {
      if (buf[j] == '.')
        continue;
      else if (is_a(buf[j]))
        da_push(&a_arr[buf[j] - 'a'], (pair){i, j});
      else if (is_A(buf[j]))
        da_push(&A_arr[buf[j] - 'A'], (pair){i, j});
      else if (is_d(buf[j]))
        da_push(&d_arr[buf[j] - '0'], (pair){i, j});
      else
        assert(0 && "well wtf");
    }
  }
  fclose(f);

  int **anodes = mat(N, N);
  for (int i = 0; i < 26; ++i)
    get_antinodes(a_arr + i, anodes);
  for (int i = 0; i < 26; ++i)
    get_antinodes(A_arr + i, anodes);
  for (int i = 0; i < 10; ++i)
    get_antinodes(d_arr + i, anodes);

  int p1 = 0;
  for (int i = 0; i < N; ++i)
    for (int j = 0; j < N; ++j)
      p1 += anodes[i][j];

  for (int i = 0; i < 26; ++i)
    get_antinodes2(a_arr + i, anodes);
  for (int i = 0; i < 26; ++i)
    get_antinodes2(A_arr + i, anodes);
  for (int i = 0; i < 10; ++i)
    get_antinodes2(d_arr + i, anodes);

  int p2 = 0;
  for (int i = 0; i < N; ++i)
    for (int j = 0; j < N; ++j)
      p2 += anodes[i][j];
  printf("p1: %d\np2: %d\n", p1, p2);

  free(*anodes);
  free(anodes);
  for (int i = 0; i < 26; ++i)
    da_clear(a_arr + i);
  for (int i = 0; i < 26; ++i)
    da_clear(A_arr + i);
  for (int i = 0; i < 10; ++i)
    da_clear(d_arr + i);
  return 0;
}

void get_antinodes(da *arr, int **anodes) {
  size_t n = arr->size;
  for (int i = 0; i < n; ++i) {
    pair pi = da_at(*arr, i);
    for (int j = i + 1; j < n; ++j) {
      pair pj = da_at(*arr, j);
      int xi = pi.x, yi = pi.y;
      int xj = pj.x, yj = pj.y;
      int dx = xi - xj, dy = yi - yj;
      if (valid_idx(xi + dx, yi + dy))
        anodes[xi + dx][yi + dy] = 1;
      if (valid_idx(xj - dx, yj - dy))
        anodes[xj - dx][yj - dy] = 1;
    }
  }
}

void get_antinodes2(da *arr, int **anodes) {
  size_t n = arr->size;
  for (int i = 0; i < n; ++i) {
    pair pi = da_at(*arr, i);
    for (int j = i + 1; j < n; ++j) {
      pair pj = da_at(*arr, j);
      int dx = pj.x - pi.x;
      int dy = pj.y - pi.y;
      int g = gcd(abs(dx), abs(dy));
      int step_x = dx / g;
      int step_y = dy / g;
      int x = pi.x, y = pi.y;
      while (valid_idx(x, y)) {
        anodes[x][y] = 1;
        x += step_x;
        y += step_y;
      }
      x = pi.x - step_x;
      y = pi.y - step_y;
      while (valid_idx(x, y)) {
        anodes[x][y] = 1;
        x -= step_x;
        y -= step_y;
      }
    }
  }
}
