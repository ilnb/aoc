#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#define LEN 130

typedef struct data {
  char *chr;
} data;

int move_top(int *steps, int *row, int *col, data *line);
int move_right(int *steps, int *row, int *col, data *line);
int move_bot(int *steps, int *row, int *col, data *line);
int move_left(int *steps, int *row, int *col, data *line);

int main(void) {
  FILE *fp = fopen("input.txt", "r");
  if (!fp) {
    printf("Trouble opening the file.\n");
    exit(1);
  }
  data *line = malloc(LEN * sizeof(data));
  // parsing
  for (int j = 0; j < LEN; j++) {
    line[j].chr = NULL;
    int i = 0;
    char *l = NULL;
    size_t len = 0;
    int r = getline(&l, &len, fp);
    if (r != -1)
      line[j].chr = l;
  }
  // position of man
  int row, col, flag = 0;
  for (int j = 0; j < LEN; j++) {
    for (int i = 0; i < LEN; i++)
      if (line[j].chr[i] == '^') {
        row = j, col = i, flag++;
        break;
      }
    if (flag)
      break;
  }
  // motion
  int steps = 0;
  flag = move_top(&steps, &row, &col, line);
  if (flag)
    printf("steps: %d\n", steps);
  fclose(fp);
  free(line);
  return 0;
}

int move_top(int *steps, int *row, int *col, data *line) {
  while (*row >= 0 && line[*row].chr[*col] != '#') {
    if (line[*row].chr[*col] != 'X') {
      (*steps)++;
      line[*row].chr[*col] = 'X';
    }
    (*row)--;
  }
  if (*row == -1)
    return 1;
  else {
    (*row)++;
    move_right(steps, row, col, line);
  }
}

int move_right(int *steps, int *row, int *col, data *line) {
  while (*col < LEN && line[*row].chr[*col] != '#') {
    if (line[*row].chr[*col] != 'X') {
      (*steps)++;
      line[*row].chr[*col] = 'X';
    }
    (*col)++;
  }
  if (*col == LEN)
    return 1;
  else {
    (*col)--;
    move_bot(steps, row, col, line);
  }
}

int move_bot(int *steps, int *row, int *col, data *line) {
  while (*row < LEN && line[*row].chr[*col] != '#') {
    if (line[*row].chr[*col] != 'X') {
      (*steps)++;
      line[*row].chr[*col] = 'X';
    }
    (*row)++;
  }
  if (*row == LEN)
    return 1;
  else {
    (*row)--;
    move_left(steps, row, col, line);
  }
}

int move_left(int *steps, int *row, int *col, data *line) {
  while (*col >= 0 && line[*row].chr[*col] != '#') {
    if (line[*row].chr[*col] != 'X') {
      (*steps)++;
      line[*row].chr[*col] = 'X';
    }
    (*col)--;
  }
  if (*col == -1)
    return 1;
  else {
    (*col)++;
    move_top(steps, row, col, line);
  }
}
