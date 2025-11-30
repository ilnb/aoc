#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
  FILE *f = fopen("input.txt", "r");
  int s1 = 0;
  char c;
  char *str = NULL;
  int index = 0;
  while ((c = fgetc(f)) != EOF) {
    index++;
    str = realloc(str, sizeof(int) * (index));
    str[index - 1] = c;
  }
  // p1
  int j = 0;
  while (j < index) {
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
  while (j < index) {
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
  fclose(f);
  printf("Without conditions: %d\nWith conditions: %d\n", s1, s2);
}
