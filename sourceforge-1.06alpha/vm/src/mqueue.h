/*
 * The Emerald Distributed Programming Language
 * 
 * Copyright (C) 2004 Emerald Authors & Contributors
 * 
 * This file is part of the Emerald Distributed Programming Language.
 *
 * The Emerald Distributed Programming Language is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License.
 *
 *  The Emerald Distributed Programming Language is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with the Emerald Distributed Programming Language; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 */

#ifndef _EMERALD_MQUEUE_H
#define _EMERALD_MQUEUE_H
#include "assert.h"
#include "dist.h"
#include "types.h"

typedef struct {
  Node id;
  int length;
  void *msg;
} Message;

/*
 * MessageQueues are an queue of messages.
 * Operations:
 *	create, destroy, insert, remove, size, and print.
 */

/*
 * Hidden, private type declarations.  The only thing
 * that applications of this package are to see is MQueue,
 * and they are to treat it as opaque:  that is, they may
 * assign it, and pass it as arguments, but not manipulate
 * what it points to directly.
 */

typedef struct MQueueRecord {
    Message *table;
    int size, count, firstfull, firstempty;
} MQueueRecord, *MQueue;

/* OPERATIONS */

/* Return a new, empty Message Queue */
MQueue MQueueCreate(void);

/* Destroy a queue */
void MQueueDestroy(MQueue);

/* Insert the message into the queue q */
void MQueueInsert(MQueue q, Node id, int length, void *msg);

/* Remove the first element from the queue */
void MQueueRemove(MQueue q, Node *idp, int *lengthp, void **msgp);

/* DEBUGGING: Print the MQueue */
void MQueuePrint(MQueue q);

/* Return the number of elements in MQueue */
#define MQueueSize(MQueue) ((MQueue)->count)

#endif /* _EMERALD_MQUEUE_H */

