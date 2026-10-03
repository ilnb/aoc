#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

int main() {
  FILE *f = fopen("input", "r");
  assert(f && "input file missing");
  int s1 = 0;
  char c;
  struct stat buf;
  stat("input", &buf);
  int len = buf.st_size;
  char *str = malloc(len);
  fread(str, sizeof(char), len, f);
  fclose(f);
  // p1
  int j = 0;
  while (j < len) {
    int offset = 1, m, n;
    if (strncmp(str + j, "mul(", 4) == 0) {
      sscanf(str + j, "mul(%d,%d)%n", &m, &n, &offset);
      if (offset != 1)
        s1 += m * n;
    }
    j += offset;
  }
  // p2
  j = 0;
  int flag = 1, s2 = 0;
  while (j < len) {
    int m, n, offset = 1;
    if (strncmp(str + j, "don't()", 7) == 0)
      flag = 0, j += 7;
    else if (strncmp(str + j, "do()", 4) == 0)
      flag = 1, j += 4;
    if (strncmp(str + j, "mul(", 4) == 0 && flag) {
      sscanf(str + j, "mul(%d,%d)%n", &m, &n, &offset);
      if (offset != 1)
        s2 += m * n;
    }
    j += offset;
  }
  free(str);
  printf("Without conditions: %d\nWith conditions: %d\n", s1, s2);
}
