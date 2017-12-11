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
/* comment me!
 */

#ifndef _EMERALD_CREATION_H
#define _EMERALD_CREATION_H

#include "types.h"

extern Object AllocateObject(ConcreteType p, int size);
extern Vector CreateVector(ConcreteType p, unsigned nelems);
extern Object CreateUninitializedObject(ConcreteType);
extern Object CreateObjectFromOutside(ConcreteType, unsigned int);
extern String CreateString(char *);

extern void run(Object o, int kind, int asynch);
extern void makeReady(struct State *state);
extern int isReady(struct State *state);
extern int bottomStackFrame(struct State *state);
extern void runState(struct State *state, int asynch);
void scheduleProcess(Object o, int opIndex);
struct State *newState(Object o, ConcreteType ct);
extern void tryToFindState(struct State *state);
void deleteState(struct State *);
void setupState(struct State *s, Object o, ConcreteType ct);
#endif /* _EMERALD_CREATION_H */
