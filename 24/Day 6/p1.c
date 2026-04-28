#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#define LEN 130

typedef struct {
  char *str;
} data;

int move_top(int *steps, int row, int col, data *line);
int move_right(int *steps, int row, int col, data *line);
int move_bot(int *steps, int row, int col, data *line);
int move_left(int *steps, int row, int col, data *line);

int main(void) {
  FILE *f = fopen("input", "r");
  assert(f && "input file missing");
  if (!f) {
    printf("Trouble opening the file.\n");
    exit(1);
  }
  data *line = malloc(LEN * sizeof(data));
  // parsing
  for (int j = 0; j < LEN; j++) {
    line[j].str = malloc(LEN + 1);
    fscanf(f, "%s\n", line[j].str);
  }
  // position of man
  int row, col, flag = 0;
  for (int j = 0; j < LEN; j++) {
    for (int i = 0; i < LEN; i++)
      if (line[j].str[i] == '^') {
        row = j, col = i, flag++;
        break;
      }
    if (flag)
      break;
  }
  // motion
  int steps = 0;
  flag = move_top(&steps, row, col, line);
  if (flag)
    printf("steps: %d\n", steps);
  fclose(f);
  for (int i = 0; i < LEN; i++)
    free(line[i].str);
  free(line);
  return 0;
}

int move_top(int *steps, int row, int col, data *line) {
  while (row >= 0 && line[row].str[col] != '#') {
    if (line[row].str[col] != 'X') {
      (*steps)++;
      line[row].str[col] = 'X';
    }
    row--;
  }
  row++;
  if (!row)
    return 1;
  return move_right(steps, row, col, line);
}

int move_right(int *steps, int row, int col, data *line) {
  while (col < LEN && line[row].str[col] != '#') {
    if (line[row].str[col] != 'X') {
      (*steps)++;
      line[row].str[col] = 'X';
    }
    col++;
  }
  col--;
  if (col == LEN - 1)
    return 1;
  return move_bot(steps, row, col, line);
}

int move_bot(int *steps, int row, int col, data *line) {
  while (row < LEN && line[row].str[col] != '#') {
    if (line[row].str[col] != 'X') {
      (*steps)++;
      line[row].str[col] = 'X';
    }
    row++;
  }
  row--;
  if (row == LEN - 1)
    return 1;
  return move_left(steps, row, col, line);
}

int move_left(int *steps, int row, int col, data *line) {
  while (col >= 0 && line[row].str[col] != '#') {
    if (line[row].str[col] != 'X') {
      (*steps)++;
      line[row].str[col] = 'X';
    }
    col--;
  }
  col++;
  if (!col)
    return 1;
  return move_top(steps, row, col, line);
}
