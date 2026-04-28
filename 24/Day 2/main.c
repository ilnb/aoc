#include <stdio.h>
#include <stdlib.h>
#define LEN 1000

int safetyCheckPtr(int *arr, int n, int *idx) {
  for (int i = 0; i < n; i++)
    for (int j = 0; j < n; j++)
      if (!arr[i]) {
        *idx = i;
        return 0;
      } else if (arr[i] > 0) {
        if (arr[j] < 0 || arr[j] > 3) {
          *idx = j;
          return 0;
        }
      } else {
        if (arr[j] > 0 || arr[j] < -3) {
          *idx = j;
          return 0;
        }
      }
  return 1;
}

int safetyCheck(int *arr, int n) {
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

void elRemove(int *arr, int n, int idx) {
  for (int i = idx; i < n - 1; i++)
    arr[i] = arr[i + 1];
}

int main() {
  FILE *fp = fopen("input", "r");
  int safe = 0, allowed = 0;
  for (int i = 0; i < LEN; i++) {
    int n = 0, p = 0;
    char c;
    while ((c = fgetc(fp)) != '\n') {
      if (c == ' ')
        n++;
      p++;
    }
    n++, p++;
    int *num = malloc(sizeof(int) * n);
    fseek(fp, -p, SEEK_CUR);
    for (int j = 0; j < n - 1; j++)
      fscanf(fp, "%d ", &num[j]);
    fscanf(fp, "%d\n", &num[n - 1]);
    int *temp = malloc(sizeof(int) * n);
    for (int j = 0; j < n; j++)
      temp[j] = num[j];
    int *diff = malloc(sizeof(int) * (n - 1));
    for (int j = 0; j < n - 1; j++)
      diff[j] = num[j + 1] - num[j];
    int idx, l;
    l = safetyCheckPtr(diff, n - 1, &idx);
    if (l)
      safe++;
    else {
      elRemove(num, n, idx);
      for (int j = 0; j < n - 2; j++)
        diff[j] = num[j + 1] - num[j];
      l = safetyCheck(diff, n - 2);
      if (l)
        allowed++;
      else {
        for (int j = 0; j < n; j++)
          num[j] = temp[j];
        elRemove(num, n, idx + 1);
        for (int j = 0; j < n - 2; j++)
          diff[j] = num[j + 1] - num[j];
        l = safetyCheck(diff, n - 2);
        if (l)
          allowed++;
        else if (idx > 0) {
          for (int j = 0; j < n; j++)
            num[j] = temp[j];
          elRemove(num, n, idx - 1);
          for (int j = 0; j < n - 2; j++)
            diff[j] = num[j + 1] - num[j];
          l = safetyCheck(diff, n - 2);
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
