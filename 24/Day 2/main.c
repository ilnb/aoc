#include <stdio.h>
#include <stdlib.h>
#define LEN 1000

int safetyCheckPtr(int *arr, int n, int *index)
{
  for (int i = 0; i < n; i++)
    for (int j = 0; j < n; j++)
      if (!arr[i]) {
        *index = i;
        return 0;
      } else if (arr[i] > 0) {
        if (arr[j] < 0 || arr[j] > 3) {
          *index = j;
          return 0;
        }
      } else {
        if (arr[j] > 0 || arr[j] < -3) {
          *index = j;
          return 0;
        }
      }
  return 1;
}

int safetyCheck(int *arr, int n)
{
  for (int i = 0; i < n; i++)
    for (int j = 0; j < n; j++)
      if (!arr[i])
        return 0;
      else if (arr[i] > 0) {
        if (arr[j] < 0 || arr[j] > 3)
          return 0;
      } else {
        if (arr[j] > 0 || arr[j] < -3)
          return 0;
      }
  return 1;
}

void elRemove(int *arr, int n, int index)
{
  int *b = malloc(sizeof(int) * (n - 1));
  for (int i = 0; i < index; i++)
    b[i] = arr[i];
  for (int i = index; i < n - 1; i++)
    b[i] = arr[i + 1];
  for (int i = 0; i < n - 1; i++)
    arr[i] = b[i];
  free(b);
}

int main()
{
  FILE *fp = fopen("input.txt", "r");
  int safe = 0, allowed = 0;
  for (int i = 0; i < LEN; i++) {
    int count = 0, p = 0;
    char c;
    while ((c = fgetc(fp)) != '\n') {
      if (c == ' ')
        count++;
      p++;
    }
    count++, p++;
    int *num = malloc(sizeof(int) * count);
    fseek(fp, -p, SEEK_CUR);
    for (int j = 0; j < count - 1; j++)
      fscanf(fp, "%d ", &num[j]);
    fscanf(fp, "%d\n", &num[count - 1]);
    int *temp = malloc(sizeof(int) * count);
    for (int j = 0; j < count; j++)
      temp[j] = num[j];
    int *diff = malloc(sizeof(int) * (count - 1));
    for (int j = 0; j < count - 1; j++)
      diff[j] = num[j + 1] - num[j];
    int index, l;
    l = safetyCheckPtr(diff, count - 1, &index);
    if (l)
      safe++;
    else {
      elRemove(num, count, index);
      for (int j = 0; j < count - 2; j++)
        diff[j] = num[j + 1] - num[j];
      l = safetyCheck(diff, count - 2);
      if (l)
        allowed++;
      else {
        for (int j = 0; j < count; j++)
          num[j] = temp[j];
        elRemove(num, count, index + 1);
        for (int j = 0; j < count - 2; j++)
          diff[j] = num[j + 1] - num[j];
        l = safetyCheck(diff, count - 2);
        if (l)
          allowed++;
        else if (index > 0) {
          for (int j = 0; j < count; j++)
            num[j] = temp[j];
          elRemove(num, count, index - 1);
          for (int j = 0; j < count - 2; j++)
            diff[j] = num[j + 1] - num[j];
          l = safetyCheck(diff, count - 2);
          if (l)
            allowed++;
        }
      }
    }
    free(num);
    free(diff);
    free(temp);
  }
  printf("safe: %d\nallowed: %d\ntotal: %d\n", safe, allowed, safe + allowed);
  fclose(fp);
  return 0;
}
