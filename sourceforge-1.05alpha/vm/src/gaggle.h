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

/*
 * Gaggles
 */
#ifndef _EMERALD_GAGGLE_H
#define _EMERALD_GAGGLE_H

#include "types.h"
#include "oidtoobj.h"
#include "vm_exp.h"
#include "oisc.h"
#include "remote.h"
#include "rinvoke.h"

typedef struct gtype *gtypeptr;

struct gtype{
  OID gmember;
  gtypeptr next;
};

extern OISc gaggleTable;
extern void createGaggle(OID g);
extern void initGaggle(void);
extern void add_gmember(OID gid, OID newMember);
extern void delete_gmember(OID gid, OID deadMember);
extern OID get_gmember(OID gid);
extern OID get_gelement(OID gid, int index);
extern int get_gsize(OID gid);
extern void sendGmUpdate(Node srv, Stream str, OID moid, OID ooid, OID ctoid, int dead);
extern void sendGaggleUpdate(OID moid, OID ooid, OID ctoid, int dead);
extern void sendGaggleNews(Node srv, Stream str);
#endif /* _EMERALD_GAGGLE_H */
