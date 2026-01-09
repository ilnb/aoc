#include <stdio.h>
#include <stdlib.h>
#define RULES 1176
#define UPDATES 194

typedef struct rule {
  int main;
  int sub;
} rule;

int checkUpdate(rule *, int *, int);
void fixer(rule *, int *, int);

void swap(int *a, int *b)
{
  int t = *a;
  *a = *b;
  *b = t;
}

int main(void)
{
  rule *rules = malloc(RULES * sizeof(rule));
  FILE *fp = fopen("input.txt", "r");
  int ordered = 0, rest = 0;
  // rule parsing
  for (int i = 0; i < RULES; i++)
    fscanf(fp, "%d|%d\n", &rules[i].main, &rules[i].sub);
  // update parsing
  for (int i = 0; i < UPDATES; i++) {
    int count = 0, offset = 0;
    char c;
    while ((c = fgetc(fp)) != '\n') {
      if (c == ',')
        count++;
      offset++;
    }
    count++, offset++;
    int *updates = malloc(sizeof(int) * count);
    fseek(fp, -offset, SEEK_CUR);
    for (int j = 0; j < count - 1; j++)
      fscanf(fp, "%d,", &updates[j]);
    fscanf(fp, "%d\n", &updates[count - 1]);
    int *kek = NULL, p = 0;
    // valid updates
    int flag = checkUpdate(rules, updates, count);
    if (flag == 1)
      ordered += updates[count / 2];
    else {
      p = count;
      kek = malloc(sizeof(int) * p);
      for (int j = 0; j < p; j++)
        kek[j] = updates[j];
    }
    // invalid ones
    if (p > 0) {
      fixer(rules, kek, p);
      rest += kek[p / 2];
    }
    free(kek);
    free(updates);
  }
  free(rules);
  fclose(fp);
  printf("ordered: %d\nrest: %d\n", ordered, rest);
  return 0;
}

int checkUpdate(rule *rules, int *updates, int count)
{
  int flag = 1;
  for (int j = 0; j < count; j++)
    for (int k = 0; k < count; k++) {
      int m = updates[j];
      int n = updates[k];
      for (int l = 0; l < RULES; l++)
        if (k > j) {
          if (m == rules[l].sub && n == rules[l].main)
            flag--;
        } else if (k < j) {
          if (m == rules[l].main && n == rules[l].sub)
            flag--;
        }
    }
  return flag;
}

void fixer(rule *rules, int *kek, int count)
{
  for (int j = 0; j < count; j++)
    for (int k = 0; k < count; k++)
      for (int l = 0; l < RULES; l++)
        if (k > j) {
          if (kek[j] == rules[l].sub && kek[k] == rules[l].main)
            swap(kek + j, kek + k);
        } else if (k < j) {
          if (kek[j] == rules[l].main && kek[k] == rules[l].sub)
            swap(kek + j, kek + k);
        }
}
