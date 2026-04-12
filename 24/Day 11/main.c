#include "str_map.h"
#include <assert.h>
#include <stdio.h>

#define N 8

char *slice(const char *, int, int);

int main() {
  FILE *f = fopen("input", "r");
  assert(f && "input file missing");

  char buf[32];
  str_map *mp = hm_create(N);
  for (int i = 0; i < N; i++) {
    fscanf(f, "%s", buf);
    hm_set(mp, buf, 1);
  }
  for (int i = 1; i <= 75; i++) {
    str_map *nxt = hm_create(mp->cap);
    for (size_t i = 0; i < mp->cap; i++) {
      entry *e = &mp->entries[i];
      if (!e->key)
        continue;

      const char *s = e->key;
      size_t len = strlen(s);
      u64 cnt = e->val;

      if (!strcmp(s, "0")) {
        hm_inc(nxt, "1", cnt);
      } else if (len & 1) {
        uint64_t val = strtoull(s, NULL, 10);
        val *= 2024;
        char buf[64];
        sprintf(buf, "%lu", val);
        hm_inc(nxt, buf, cnt);
      } else {
        size_t m = len / 2;
        char *l = slice(s, 0, m);
        char *r = slice(s, m, m);
        hm_inc(nxt, l, cnt);
        hm_inc(nxt, r, cnt);
        free(l), free(r);
      }
    }
    hm_free(mp);
    mp = nxt;
    if (i == 25) {
      size_t p1 = 0;
      for (size_t i = 0; i < mp->cap; i++) {
        if (mp->entries[i].key != NULL)
          p1 += mp->entries[i].val;
      }
      printf("p1: %lu\n", p1);
    } else if (i == 75) {
      size_t p2 = 0;
      for (size_t i = 0; i < mp->cap; i++) {
        if (mp->entries[i].key != NULL)
          p2 += mp->entries[i].val;
      }
      printf("p2: %lu\n", p2);
    }
  }
  hm_free(mp);
  fclose(f);
  return 0;
}

char *slice(const char *s, int start, int len) {
  char *res = malloc(len + 1);
  memcpy(res, s + start, len);
  res[len] = 0;
  int i = 0;
  while (i < len - 1 && res[i] == '0')
    i++;

  if (i > 0)
    memmove(res, res + i, len - i + 1);
  return res;
}
