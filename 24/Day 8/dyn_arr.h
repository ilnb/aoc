#ifndef _DA_H
#define _DA_H

#include <stdlib.h>

/* define a dynamic array of typename @name containing type @type */
#define DEF_DA(name, type)                                                                         \
  typedef struct {                                                                                 \
    int size, capacity;                                                                            \
    type *arr;                                                                                     \
  } name;                                                                                          \
                                                                                                   \
  /* initialize the array */                                                                       \
  static inline void name##_init(name *v) {                                                        \
    v->size = v->capacity = 0;                                                                     \
    v->arr = NULL;                                                                                 \
  }                                                                                                \
                                                                                                   \
  /* clears and resets the array */                                                                \
  static inline void name##_clear(name *v) {                                                       \
    if (v->arr)                                                                                    \
      free(v->arr);                                                                                \
    v->size = v->capacity = 0;                                                                     \
    v->arr = NULL;                                                                                 \
  }                                                                                                \
                                                                                                   \
  /* pushes @elem to the back of the array */                                                      \
  static inline void name##_push(name *v, type elem) {                                             \
    if (v->size == v->capacity) {                                                                  \
      v->capacity = v->capacity ? v->capacity * 2 : 4;                                             \
      v->arr = realloc(v->arr, v->capacity * sizeof *v->arr);                                      \
    }                                                                                              \
    v->arr[v->size++] = elem;                                                                      \
  }                                                                                                \
                                                                                                   \
  /* pops the array by one */                                                                      \
  static inline void name##_pop(name *v) {                                                         \
    v->arr[v->size-- - 1] = (type){0};                                                             \
    if (!v->size)                                                                                  \
      name##_clear(v);                                                                             \
  }                                                                                                \
                                                                                                   \
  /* sets the capacity to @new_cap, resets all data */                                             \
  static inline void name##_reserve(name *v, int new_cap) {                                        \
    v->size = v->capacity = new_cap;                                                               \
    free(v->arr);                                                                                  \
    v->arr = calloc(new_cap, sizeof *v->arr);                                                      \
  }                                                                                                \
                                                                                                   \
  /* shrinks the capacity to size */                                                               \
  static inline void name##_shrink(name *v) {                                                      \
    if (v->size < v->capacity) {                                                                   \
      v->capacity = v->size;                                                                       \
      v->arr = realloc(v->arr, v->capacity * sizeof *v->arr);                                      \
    }                                                                                              \
  }                                                                                                \
                                                                                                   \
  /* grows the array to @new_cap */                                                                \
  static inline void name##_grow(name *v, unsigned int new_cap) {                                  \
    if (new_cap <= v->capacity)                                                                    \
      return;                                                                                      \
    v->arr = realloc(v->arr, new_cap * sizeof *v->arr);                                            \
    v->capacity = new_cap;                                                                         \
  }                                                                                                \
                                                                                                   \
  /* inserts @elem at index @idx */                                                                \
  static inline void name##_insert(name *v, int idx, type elem) {                                  \
    if (idx < 0 || idx > v->size)                                                                  \
      return;                                                                                      \
    if (v->size == v->capacity) {                                                                  \
      v->capacity = v->capacity ? v->capacity * 2 : 4;                                             \
      v->arr = realloc(v->arr, v->capacity * sizeof *v->arr);                                      \
    }                                                                                              \
    for (int i = v->size; i > idx; i--)                                                            \
      v->arr[i] = v->arr[i - 1];                                                                   \
    v->arr[idx] = elem;                                                                            \
    v->size++;                                                                                     \
  }                                                                                                \
                                                                                                   \
  /* erases @elem at index @idx */                                                                 \
  static inline void name##_erase(name *v, int idx) {                                              \
    if (idx < 0 || idx >= v->size)                                                                 \
      return;                                                                                      \
    for (int i = idx; i < v->size - 1; i++)                                                        \
      v->arr[i] = v->arr[i + 1];                                                                   \
    v->size--;                                                                                     \
    if (v->size < v->capacity / 2)                                                                 \
      name##_shrink(v);                                                                            \
  }

#define da_at(v, i) ((v).arr[i])
#define da_for_each(v, i) for (i = 0; i < (v).size; ++i)
#define da_for_each_rev(v, i) for (i = (v).size - 1; i > -1; --i)

#endif /* _DA_H */
