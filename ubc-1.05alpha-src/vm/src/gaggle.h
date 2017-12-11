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
