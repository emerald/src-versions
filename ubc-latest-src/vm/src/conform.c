#define E_NEEDS_STRING
#include "system.h"

#include "types.h"
#include "assert.h"
#include "ooisc.h"
#include "trace.h"
#include "globals.h"
#include "oidtoobj.h"

static OOISc assumeMap = 0;
static OOISc conformMap = 0;
static int iconforms(AbstractType, AbstractType, int);

int conforms(AbstractType a, AbstractType b)
{
  int res;
  assumeMap = OOIScCreate();
  res = iconforms(a, b, 0);
  OOIScDestroy(assumeMap);
  assumeMap = 0;
  return res;
}

static char *pad(int l)
{
  while (l-- > 0) {
    printf("  ");
  }
  return 0;
}

static int samename(ATOpVectorElement aove, ATOpVectorElement bove)
{
  return (aove->d.name->d.items == bove->d.name->d.items &&
	  VLen(aove->d.arguments) == VLen(bove->d.arguments) &&
	  !strncmp((char *)aove->d.name->d.data, 
		   (char *)bove->d.name->d.data,
		   bove->d.name->d.items));
}

#define DONE(x) { result = x; goto done; }

static int iconforms(AbstractType a, AbstractType b, int l)
{
  OID ao, bo;
  int result, i, j, k, found, foundincache = 0;
  ATOpVectorElement aove, bove;

  if (!conformMap) conformMap = OOIScCreate();
  assert(assumeMap);
  if (ISNIL(a) || ISNIL(b)) {
    TRACE(conform, 0, ("emx: conforms on nil type"));
    return 1;
  }

  ao = OIDOf(a);
  bo = OIDOf(b);
  TRACE(conform, 2, ((pad(l), "==> %.*s (%#x) vs %.*s (%#x)"), 
		     a->d.name->d.items,
		     a->d.name->d.data,
		     ao.Seq,
		     b->d.name->d.items,
		     b->d.name->d.data,
		     bo.Seq));
  l++;
  result = OOIScLookup(conformMap, ao, bo);
  if (result >= 0) {
    TRACE(conform, 2, ((pad(l), "Found answer in cache")));
    foundincache = 1;
    DONE(result);
  }
  result = OOIScLookup(assumeMap, ao, bo);
  if (result >= 0) {
    TRACE(conform, 2, ((pad(l), "We are assuming these conform")));
    DONE(result);
  }
  if (a == BuiltinInstAT(NILI)) {
    TRACE(conform, 2, ((pad(l), "%.*s is None"),
	   a->d.name->d.items,
	   a->d.name->d.data));
    DONE(1);
  }
  if (b == BuiltinInstAT(ANYI)) {
    TRACE(conform, 2, ((pad(l), "%.*s is Any"),
		       b->d.name->d.items,
		       b->d.name->d.data));
    DONE(1);
  } 
  if (b == BuiltinInstAT(NILI)) {
    TRACE(conform, 2, ((pad(l), "%.*s is None"),
		       b->d.name->d.items,
		       b->d.name->d.data));
    DONE(0);
  } 
  if (a == b) {
    TRACE(conform, 2, ((pad(l), "%.*s == %.*s"),
		       a->d.name->d.items,
		       a->d.name->d.data,
		       b->d.name->d.items,
		       b->d.name->d.data));
    DONE(1);
  } 
  if (EqOID(ao, bo)) {
    TRACE(conform, 2, ((pad(l), "%.*s = %.*s"),
		       a->d.name->d.items,
		       a->d.name->d.data,
		       b->d.name->d.items,
		       b->d.name->d.data));
    DONE(1);
  } 
  if (b->d.flags & AT_ISVECTOR) {
    if (!(a->d.flags & AT_ISVECTOR)) {
      TRACE(conform, 2, ((pad(l), "%.*s is a vector and %.*s is not"),
			 a->d.name->d.items,
			 a->d.name->d.data,
			 b->d.name->d.items,
			 b->d.name->d.data));
      DONE(0);
    }
  } else if (isNoNode(bo) && isBuiltinINSTAT(bo.Seq) &&
	     (bo.Seq == OIDOfBuiltin(B_INSTAT, BOOLEANI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, CHARACTERI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, INTEGERI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, NODEI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, SIGNATUREI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, REALI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, STRINGI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, TIMEI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, NODELISTELEMENTI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, NODELISTI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, INSTREAMI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, OUTSTREAMI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, BITCHUNKI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, CONCRETETYPEI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, COPVECTORI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, COPVECTOREI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, AOPVECTORI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, AOPVECTOREI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, APARAMLISTI) ||
	      bo.Seq == OIDOfBuiltin(B_INSTAT, INTERPRETERSTATEI))) {
    TRACE(conform, 2, ((pad(l), "%.*s is a cannot-be-conformed-to builtin"),
		       b->d.name->d.items,
		       b->d.name->d.data));
    DONE(0);
  } 
  if (b->d.flags & AT_ISIMMUTABLE
      && !a->d.flags & AT_ISIMMUTABLE) {
    TRACE(conform, 2, ((pad(l), "%.*s is not immutable"), 
		       a->d.name->d.items,
		       a->d.name->d.data));
    DONE(0);
  } 
  if (a->d.ops->d.items < b->d.ops->d.items) {
    TRACE(conform, 2, ((pad(l), "%.*s doesn't have enough operations"),
		       a->d.name->d.items,
		       a->d.name->d.data));
    DONE(0);
  }
  OOIScInsert(assumeMap, ao, bo, 1);
  for (i = 0; i < b->d.ops->d.items; i++) {
    bove = b->d.ops->d.data[i];
    found = 0;
    TRACE(conform, 4, ((pad(l-1), "Looking for operation %.*s[%d]"),
		       bove->d.name->d.items,
		       bove->d.name->d.data,
		       VLen(bove->d.arguments)));
    for (j = 0;
	 j < a->d.ops->d.items;
	 j++) {
      aove = a->d.ops->d.data[j];
      if (samename(aove, bove)) {
	if (bove->d.isFunction
	    && !aove->d.isFunction) {
	  TRACE(conform, 2, ((pad(l), "Operation %.*s[%d] is not a function"),
			     aove->d.name->d.items,
			     aove->d.name->d.data,
			     VLen(aove->d.arguments)));
	  DONE(0);
	}
	if (!ISNIL(aove->d.arguments)) {
	  for (k = 0; k < aove->d.arguments->d.items; k++) {
	    TRACE(conform, 4, ((pad(l-1), "Checking argument %d"), k));
	    if (!iconforms(bove->d.arguments->
			   d.data[k],
			   aove->d.arguments->
			   d.data[k], l+1)) {
	      TRACE(conform, 2, ((pad(l), "Operation %.*s[%d] argument %d doesn't conform"),
				 aove->d.name->d.items,
				 aove->d.name->d.data,
				 VLen(aove->d.arguments), k));
	      DONE(0);
	    }
	  }
	}
	if (!ISNIL(aove->d.results)) {
	  for (k = 0;
	       k < aove->d.results->d.items;
	       k++) {
	    TRACE(conform, 4, ((pad(l-1), "Checking result %d"), k));
	    if (!iconforms(aove->d.results->
			   d.data[k],
			   bove->d.results->
			   d.data[k], l+1)) {
	      TRACE(conform, 2, ((pad(l), "Operation %.*s[%d] result %d doesn't conform"),
				 aove->d.name->d.items,
				 aove->d.name->d.data, k));
	      DONE(0);
	    }
	  }
	}
	found = 1;
	break;
      }
    }
    if (!found) {
      TRACE(conform, 2, ((pad(l), "Operation %.*s[%d] is not defined"),
			 bove->d.name->d.items,
			 bove->d.name->d.data,
			 VLen(bove->d.arguments)));
      DONE(0);
    }
  }
  result = 1;
 done:
  l--;
  TRACE(conform, 2, ((pad(l), "<== %s"), result ? "yes" : "no"));
  if (l == 0 && !foundincache) {
    OOIScInsert(conformMap, ao, bo, result);
  }
  return result;
}

