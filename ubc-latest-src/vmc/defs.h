#include "iisc.h"
#include "sisc.h"
#include "iset.h"
#include "slist.h"
#include "ilist.h"
#include "assert.h"

struct identifier_entry {
    char *name;		/* character string key for this entry */
    int  token;		/* token (id or some keyword) */    
    int  lineno;	/* source line number */
};

typedef struct thing {
  ISet first;
  ISet follow;
  int nrules;
  struct rule **rules;
} thing;

typedef struct rule {
  int nsymbols;
  ISet first;
  ISet director;
  struct identifier_entry **symbols;
} rule;
extern thing *currentthing;
extern rule  *currentrule;
typedef struct identifier_entry symbol;
extern symbol *first;
