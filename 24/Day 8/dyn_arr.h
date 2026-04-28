#ifndef _DA_H
#define _DA_H

#include <stdlib.h>

/* define a dynamic itemsay of typename @name containing type @type */
#define DEF_DA(name, type)                                                                         \
  typedef struct {                                                                                 \
    int size, capacity;                                                                            \
    type *items;                                                                                   \
  } name;                                                                                          \
                                                                                                   \
  /* initialize the itemsay */                                                                     \
  static inline void name##_init(name *v) {                                                        \
    v->size = v->capacity = 0;                                                                     \
    v->items = NULL;                                                                               \
  }                                                                                                \
                                                                                                   \
  /* clears and resets the itemsay */                                                              \
  static inline void name##_clear(name *v) {                                                       \
    if (v->items)                                                                                  \
      free(v->items);                                                                              \
    v->size = v->capacity = 0;                                                                     \
    v->items = NULL;                                                                               \
  }                                                                                                \
                                                                                                   \
  /* pushes @elem to the back of the itemsay */                                                    \
  static inline void name##_push(name *v, type elem) {                                             \
    if (v->size == v->capacity) {                                                                  \
      v->capacity = v->capacity ? v->capacity * 2 : 4;                                             \
      v->items = realloc(v->items, v->capacity * sizeof *v->items);                                \
    }                                                                                              \
    v->items[v->size++] = elem;                                                                    \
  }                                                                                                \
                                                                                                   \
  /* pops the itemsay by one */                                                                    \
  static inline void name##_pop(name *v) {                                                         \
    v->items[v->size-- - 1] = (type){0};                                                           \
    if (!v->size)                                                                                  \
      name##_clear(v);                                                                             \
  }                                                                                                \
                                                                                                   \
  /* sets the capacity to @new_cap, resets all data */                                             \
  static inline void name##_reserve(name *v, int new_cap) {                                        \
    v->size = v->capacity = new_cap;                                                               \
    free(v->items);                                                                                \
    v->items = calloc(new_cap, sizeof *v->items);                                                  \
  }                                                                                                \
                                                                                                   \
  /* shrinks the capacity to size */                                                               \
  static inline void name##_shrink(name *v) {                                                      \
    if (v->size < v->capacity) {                                                                   \
      v->capacity = v->size;                                                                       \
      v->items = realloc(v->items, v->capacity * sizeof *v->items);                                \
    }                                                                                              \
  }                                                                                                \
                                                                                                   \
  /* grows the itemsay to @new_cap */                                                              \
  static inline void name##_grow(name *v, unsigned int new_cap) {                                  \
    if (new_cap <= v->capacity)                                                                    \
      return;                                                                                      \
    v->items = realloc(v->items, new_cap * sizeof *v->items);                                      \
    v->capacity = new_cap;                                                                         \
  }                                                                                                \
                                                                                                   \
  /* inserts @elem at index @idx */                                                                \
  static inline void name##_insert(name *v, int idx, type elem) {                                  \
    if (idx < 0 || idx > v->size)                                                                  \
      return;                                                                                      \
    if (v->size == v->capacity) {                                                                  \
      v->capacity = v->capacity ? v->capacity * 2 : 4;                                             \
      v->items = realloc(v->items, v->capacity * sizeof *v->items);                                \
    }                                                                                              \
    for (int i = v->size; i > idx; i--)                                                            \
      v->items[i] = v->items[i - 1];                                                               \
    v->items[idx] = elem;                                                                          \
    v->size++;                                                                                     \
  }                                                                                                \
                                                                                                   \
  /* erases @elem at index @idx */                                                                 \
  static inline void name##_erase(name *v, int idx) {                                              \
    if (idx < 0 || idx >= v->size)                                                                 \
      return;                                                                                      \
    for (int i = idx; i < v->size - 1; i++)                                                        \
      v->items[i] = v->items[i + 1];                                                               \
    v->size--;                                                                                     \
    if (v->size < v->capacity / 2)                                                                 \
      name##_shrink(v);                                                                            \
  }

#define da_for_each(v, i) for (i = 0; i < (v).size; ++i)
#define da_for_each_rev(v, i) for (i = (v).size - 1; i > -1; --i)

#endif /* _DA_H */
