#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define N 40

#define valid_idx(nx, ny) (nx >= 0 && nx < N && ny >= 0 && ny < N)

int dirs[5] = {-1, 0, 1, 0, -1};

void dfs(int mat[N][N], int vis[N][N], int x, int y, int curr) {
  if (curr == 9) {
    vis[x][y]++;
    return;
  }

  for (int i = 0; i < 4; ++i) {
    int nx = x + dirs[i];
    int ny = y + dirs[i + 1];

    if (valid_idx(nx, ny) && mat[nx][ny] == curr + 1)
      dfs(mat, vis, nx, ny, curr + 1);
  }
}

int main() {
  char buf[40];
  FILE *f = fopen("input", "r");
  assert(f && "input file missing");

  int data[N][N];
  for (int i = 0; i < N; ++i) {
    fscanf(f, "%s\n", buf);
    for (int j = 0; j < N; ++j)
      data[i][j] = buf[j] - '0';
  }
  fclose(f);

  int vis[N][N] = {0};
  size_t p1 = 0, p2 = 0;
  for (int i = 0; i < N; ++i) {
    for (int j = 0; j < N; ++j) {
      if (data[i][j] == 0) {
        dfs(data, vis, i, j, 0);
        for (int i = 0; i < N; ++i) {
          for (int j = 0; j < N; ++j) {
            if (vis[i][j])
              p1++, p2 += vis[i][j];
          }
        }
        memset(vis, 0, N * N * sizeof(int));
      }
    }
  }

  printf("p1: %zu\np2: %zu\n", p1, p2);
  return 0;
}
