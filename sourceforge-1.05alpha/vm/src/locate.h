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

#ifndef _EMERALD_LOCATE_H
#define _EMERALD_LOCATE_H

#ifndef _EMERALD_ISET_H
#include "iset.h"
#endif

#ifndef _EMERALD_OISC_H
#include "oisc.h"
#endif

#ifndef _EMERALD_TYPES_H
#include "types.h"
#endif

#ifndef _EMERALD_DIST_H
#include "dist.h"
#endif

#ifndef _EMERALD_RINVOKE_H
#include "rinvoke.h"
#endif

#define LOCATE_TIMES_TO_TRY 5

typedef struct locationRecord {
  OID  oid, ctoid;
  enum { LEasy, LAggressive } stage;
  int count;
  ISet outstandingRequests;
  ISet waitingStates;
  ISet waitingMsgs;
} locationRecord;

extern OISc outstandingLocates;

extern void aggressivelyLocate(Object);
extern void locateHandleDown(noderecord *nd);
#endif
