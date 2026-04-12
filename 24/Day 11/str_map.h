#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#ifndef _STR_MAP_H
#define _STR_MAP_H

typedef uint64_t u64;

typedef struct {
  char *key;
  u64 val;
} entry;

typedef struct {
  entry *entries;
  size_t cap;
  size_t count;
} str_map;

u64 hash_key(const char *key) {
  u64 hash = 0xcbf29ce484222325;
  while (*key) {
    hash ^= (unsigned char)*key++;
    hash *= 0x100000001b3;
  }
  return hash;
}

str_map *hm_create(size_t cap) {
  str_map *mp = malloc(sizeof(str_map));
  mp->cap = cap;
  mp->count = 0;
  mp->entries = calloc(cap, sizeof(entry));
  return mp;
}

static entry *find_entry(entry *entries, size_t cap, const char *key) {
  u64 idx = hash_key(key) % cap;
  while (1) {
    entry *entry = &entries[idx];
    if (!entry->key || !strcmp(entry->key, key))
      return entry;
    idx = (idx + 1) % cap;
  }
}

void hm_set(str_map *mp, const char *key, u64 val) {
  if (mp->count > mp->cap * 0.7) {
    size_t new_cap = mp->cap * 2;
    entry *new = calloc(new_cap, sizeof(entry));
    for (size_t i = 0; i < mp->cap; i++) {
      if (mp->entries[i].key) {
        entry *dest = find_entry(new, new_cap, mp->entries[i].key);
        dest->key = mp->entries[i].key;
        dest->val = mp->entries[i].val;
      }
    }
    free(mp->entries);
    mp->entries = new;
    mp->cap = new_cap;
  }

  entry *entry = find_entry(mp->entries, mp->cap, key);
  if (!entry->key) {
    entry->key = strdup(key);
    mp->count++;
  }
  entry->val = val;
}

void hm_inc(str_map *mp, const char *key, u64 amt) {
  if (mp->count > mp->cap * 0.7) {
    size_t new_cap = mp->cap * 2;
    entry *new = calloc(new_cap, sizeof(entry));
    for (size_t i = 0; i < mp->cap; i++) {
      if (mp->entries[i].key) {
        entry *dest = find_entry(new, new_cap, mp->entries[i].key);
        dest->key = mp->entries[i].key;
        dest->val = mp->entries[i].val;
      }
    }
    free(mp->entries);
    mp->entries = new;
    mp->cap = new_cap;
  }
  entry *entry = find_entry(mp->entries, mp->cap, key);

  if (entry->key == NULL) {
    entry->key = strdup(key);
    entry->val = amt;
    mp->count++;
  } else {
    entry->val += amt;
  }
}

u64 hm_get(str_map *mp, const char *key) {
  entry *entry = find_entry(mp->entries, mp->cap, key);
  return entry->key ? entry->val : 0;
}

void hm_free(str_map *mp) {
  if (mp == NULL)
    return;
  for (size_t i = 0; i < mp->cap; i++)
    if (mp->entries[i].key != NULL)
      free(mp->entries[i].key);
  free(mp->entries);
  free(mp);
}

#endif // _STR_MAP_H
