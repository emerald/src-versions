/*
 *  Message Queue:  Expanding arrays of messages
 *  Adopted from Dr. Norm Hutchinson's iset.c
 *
 *  In sequence structure, count is the current number of items in the 
 *  array, size is the physical length of the array
 */

#include "system.h"

#include "assert.h"
#include "mqueue.h"

/* Return a new, empty queue */
MQueue MQueueCreate(void)
{
  register MQueue q;

  q = (MQueue) vmMalloc(sizeof(MQueueRecord));
  if (q == NULL) return NULL;
  q->size = 16;
  q->count = 0;
  q->table = (Message *) vmMalloc((unsigned) q->size * sizeof(Message));
  if (q->table == NULL) {
    vmFree(q);
    return NULL;
  }
  q->firstfull = 0;
  q->firstempty = 0;
  return q;
}

void MQueueDestroy(MQueue q)
{
  vmFree((char *)q->table);
  vmFree((char *)q);
}

#ifdef DISTRIBUTED
/* Expand the array.  Each element in the table is copied 
 * in the new table.  
 */
static void ExpandTable(MQueue q)
{
  register int oldTableSize = q->size, i;

  assert(q->firstfull == q->firstempty);
  q->size *= 2;
  q->table = (Message *)vmRealloc(q->table, (q->size *sizeof(Message)));
  for (i = 0; i < q->firstempty; i++) {
    q->table[oldTableSize + i] = q->table[i];
  }
  q->firstempty += oldTableSize;
}

/* Add the key to the end of q */
void MQueueInsert(MQueue q, Node id, int length, void *msg)
{
  if (q->count >= q->size) ExpandTable(q);
  q->table[q->firstempty].id = id;
  q->table[q->firstempty].length = length;
  q->table[q->firstempty].msg = msg;
  q->count++;
  q->firstempty = (q->firstempty + 1) & (q->size - 1);
}

/* Remove the entry, if it is there */
void MQueueRemove(MQueue q, Node *idp, int *lengthp, void **msgp)
{
  assert(q->count > 0);
  *idp = q->table[q->firstfull].id;
  *lengthp = q->table[q->firstfull].length;
  *msgp = q->table[q->firstfull].msg;
  q->firstfull = (q->firstfull + 1) & (q->size - 1);
  q->count --;
}

#ifndef DEBUGSC
/* DEBUGGING: Print the q */
void MQueuePrint(MQueue q)
{
  Message m;
  int i;

  printf(
    "\nDump of q @ 0x%#x, %d entr%s, current max %d\n",
    (unsigned int)q, q->count, q->count == 1 ? "y" : "ies",  q->size);
  for (i = 0; i < q->count; i++) {
    m = q->table[(q->firstfull + i) & (q->size - 1)];
    printf("%s %d %#x\n", NodeString(m.id), m.length, *(unsigned int *)m.msg);
  }
}
#endif
#endif
