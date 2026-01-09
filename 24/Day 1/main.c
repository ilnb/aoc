#include <stdio.h>
#include <stdlib.h>
#define LEN 1000

void selsort(int *arr, int n)
{
  for (int i = 0; i < n - 1; i++) {
    int min = i;
    for (int j = i + 1; j < n; j++)
      if (arr[j] < arr[min])
        min = j;
    int t = arr[min];
    arr[min] = arr[i];
    arr[i] = t;
  }
}

int main(void)
{
  FILE *fp = fopen("input.txt", "r");
  int *num1 = malloc(sizeof(int) * LEN);
  int *num2 = malloc(sizeof(int) * LEN);
  for (int i = 0; i < LEN; i++)
    fscanf(fp, "%d   %d\n", num1 + i, num2 + i);
  selsort(num1, LEN);
  selsort(num2, LEN);
  int dis = 0;
  for (int i = 0; i < LEN; i++) {
    int n = num1[i] - num2[i];
    dis += abs(n);
  }
  int sim = 0;
  for (int i = 0; i < LEN; i++) {
    int count = 0;
    for (int j = 0; j < LEN; j++)
      if (num1[i] == num2[j])
        count++;
    sim += num1[i] * count;
  }
  printf("Distance: %d\nSimilarity score: %d\n", dis, sim);
  free(num1);
  free(num2);
  fclose(fp);
  return 0;
}
