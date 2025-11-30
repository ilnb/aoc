#include <malloc.h>
#include <stdio.h>
#include <string.h>

#define LEN 140

typedef struct data {
  char *str;
} data;

int main(void) {
  int xmas = 0;
  FILE *fp = fopen("input.txt", "r");
  data *line = malloc(LEN * sizeof(data));
  for (int j = 0; j < LEN; j++) {
    char c;
    int i = 0;
    line[j].str = malloc(LEN);
    while ((c = fgetc(fp)) != '\n') {
      line[j].str[i] = c;
      i++;
    }
  }
  // horizontal
  for (int i = 0; i < LEN; i++)
    for (int j = 0; j < LEN; j++)
      if (line[j].str[i] == 'X' || line[j].str[i] == 'S')
        if (!strncmp(line[j].str + i, "XMAS", 4) ||
            !strncmp(line[j].str + i, "SAMX", 4))
          xmas++;
  // vertical
  for (int i = 0; i < LEN; i++)
    for (int j = 0; j < LEN - 3; j++)
      if (line[j].str[i] == 'X' || line[j].str[i] == 'S') {
        char s[5] = {0};
        for (int k = 0; k < 0 + 4; k++)
          s[k] = line[k + j].str[i];
        if (!strncmp(s, "SAMX", 4) || !strncmp(s, "XMAS", 4))
          xmas++;
      }
  // diagonal forward
  for (int i = 0; i < LEN - 3; i++)
    for (int j = 0; j < LEN - 3; j++)
      if (line[j].str[i] == 'X' || line[j].str[i] == 'S') {
        char s[5];
        for (int k = 0; k < 4; k++)
          s[k] = line[k + j].str[i + k];
        if (!strncmp(s, "SAMX", 4) || !strncmp(s, "XMAS", 4))
          xmas++;
      }
  // diagonal backward
  for (int i = 2; i < LEN; i++)
    for (int j = 0; j < LEN - 3; j++)
      if (line[j].str[i] == 'X' || line[j].str[i] == 'S') {
        char s[5] = {0};
        for (int k = 0; k < 0 + 4; k++)
          s[k] = line[k + j].str[i - k];
        if (!strncmp(s, "SAMX", 4) || !strncmp(s, "XMAS", 4))
          xmas++;
      }
  // mas
  int mas = 0;
  for (int i = 1; i < LEN - 1; i++)
    for (int j = 1; j < LEN - 1; j++)
      if (line[j].str[i] == 'A') {
        if ((line[j + 1].str[i - 1] == 'M' && line[j - 1].str[i - 1] == 'M' &&
             line[j + 1].str[i + 1] == 'S' && line[j - 1].str[i + 1] == 'S'))
          mas++;
        else if ((line[j + 1].str[i - 1] == 'S' &&
                  line[j - 1].str[i - 1] == 'S' &&
                  line[j + 1].str[i + 1] == 'M' &&
                  line[j - 1].str[i + 1] == 'M'))
          mas++;
        else if ((line[j + 1].str[i - 1] == 'M' &&
                  line[j + 1].str[i + 1] == 'M' &&
                  line[j - 1].str[i - 1] == 'S' &&
                  line[j - 1].str[i + 1] == 'S'))
          mas++;
        else if ((line[j + 1].str[i - 1] == 'S' &&
                  line[j + 1].str[i + 1] == 'S' &&
                  line[j - 1].str[i - 1] == 'M' &&
                  line[j - 1].str[i + 1] == 'M'))
          mas++;
      }
  printf("xmas: %d\nmas: %d\n", xmas, mas);
  free(line);
  fclose(fp);
  return 0;
}
