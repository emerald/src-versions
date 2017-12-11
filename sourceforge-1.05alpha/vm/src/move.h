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

#ifndef _EMERALD_MOVE_H
#define _EMERALD_MOVE_H

#ifndef _EMERALD_ISET_H
#include "iset.h"
#endif

#ifndef _EMERALD_REMOTE_H
#include "remote.h"
#endif

extern void sendNVars(Stream str, int n, int *args, Object ep, ConcreteType et);
extern void extractNVars(Stream str, int n, int *args, Object *epp, ConcreteType *etp, Node srv);
extern void findActivationsInObject(Object obj, Stream str);
extern int addActivations(struct State *state, Stream str, int ready);
extern int move(int option1, Object obj, Node srv, struct State *state);
extern void fixHere(Object o);
extern void doIsFixed(Object o, struct State *state, int option);
extern void unfixHere(Object o);
extern int isFixedHere(Object o);
extern void moveHandleDown(struct noderecord *);
#endif /* _EMERALD_MOVE_H */
