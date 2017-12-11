/*
 * @(#)ilist.c	1.2  5/14/89
 */
/*
 * Sequences:  Expanding arrays of keys
 *  Adopted by Kim Gillies from Dr. Norm Hutchinson's iset.c
 *  In sequence structure, count is the current number of items in the 
 *  array, size is the physical length of the array
 */

#ifndef NULL
#include <stdio.h>
#endif

#ifndef assert
#include <assert.h>
#endif

#include "ilist.h"

static int sizes[] = {
  5, 7, 17, 31,
  67, 131, 257, 521,
  1031, 2053, 4099, 8093,
  16193, 32377, 65557, 131071,
  262187, 524869, 1048829, 2097223,
  4194371, 8388697, 16777291 };

/* Return a new, empty ISet */
IList IListCreate()
{
  register int i;
  register IList sq;

  sq = (IList) malloc(sizeof(IListRecord));
  if (sq == NULL) return NULL;
  sq->size = sizes[0];
  sq->count = 0;
  sq->table = (IListTEPtr) malloc((unsigned) sq->size * sizeof(IListTE));
  if (sq->table == NULL) return NULL;
  for (i = 0; i < sq->size; i++) {
    sq->table[i].key = (int)NULL;
  }
  return sq;
}

void IListDestroy(sq)
register IList sq;
{
  free((char *)sq->table);
  free((char *)sq);
}

/* Expand the array.  Each element in the table is copied 
 * in the new table.  The new space is initialized to NULL
 */
static void ExpandTable(sq)
register IList sq;
{
  register int oldTableSize = sq->size, i;

  for (i = 0; sizes[i] <= oldTableSize; i++) ;
  sq->size = sizes[i];			/* the new size  */
  sq->table = (IListTEPtr)realloc(sq->table, (sq->size *sizeof(IListTE)));
  for (i = oldTableSize; i < sq->size; i++) {
    sq->table[i].key = (int)NULL;
  }
}

/* Is key in the sequence sq, if so--return it (probably stupid) */
IListDomainType IListMember(sq, key)
register IList sq;
register IListDomainType  key;
{
  register IListTEPtr e;
  register int index, count;

  count = sq->count;
  for (index = 0; index < count; index++) {
    e = &sq->table[index];
    if (IListCOMPARE(e->key, key)) {
      return e->key;
    }
  }
  /* nothing found */
  return (int)NULL;
}

/* Add the key to the end of sq */
void IListInsert(sq, key)
register IList sq;
register IListDomainType key;
{
  register int count;

  count = sq->count;
  if (count >= sq->size) ExpandTable(sq);
  sq->table[count].key = key;
  sq->count++;
}

/* Remove the entry, if it is there */
void IListDelete(sq, key)
register IList sq;
register IListDomainType key;
{
  register int index, count, j;

  count = sq->count;
  for (index = 0; index < count; index++) {
    if (IListCOMPARE(sq->table[index].key, key)) {
      for (j = index+1; j < count; j++) {
	sq->table[j-1].key = sq->table[j].key;
      }
      sq->count--;
      return;
    }
  }
}

/* DEBUGGING: Print the sq */
void IListPrint(sq)
register IList sq;
{
  IListDomainType key;
  int index;

  printf(
    "\nDump of sq @ 0x%05x, %d entr%s, current max %d\n\
    Index\tKey\n",
    sq, sq->count, sq->count == 1 ? "y" : "ies",  sq->size);
  for (index = 0; index < sq->size; index++) {
    key = sq->table[index].key;
    printf("%3d\t%-16.16d\n", index, key);
  }
}
