/* comment me!
 */

#include "system.h"

#include "types.h"
#include "globals.h"
#include "jsys.h"
#include "creation.h"

int obsoletesys(struct State *state)
{
  printf("Obsolete JSYS\n");
  abort();
  return 1;
}

int codeptrextra;
Object BuiltinGlobalArray[NUMBUILTINS][NUMTAGS];
int totalbytecodes;
String TrueString, FalseString;
Node MyNode;
char *gRootNode;
int (*sysfuncs[JSYS_OPS])(struct State *) = {
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       getstdin,
       getstdout,
       gettod,
       getlnn,
       getname,
       obsoletesys,
       obsoletesys,
       getactivenodes,
       getallnodes,
       delay,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       obsoletesys,
       jislocal,
       obsoletesys,
       jmove,
       jfix,
       junfix,
       jrefix,
       jlocate,
       jisfixed,
       jgetIncarnationTime,
       jgetLoadAverage
     };

void initGlobals()
{
  TrueString = CreateString("true");
  FalseString = CreateString("false");
}
