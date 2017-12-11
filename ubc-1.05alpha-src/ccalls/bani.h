/*
 * bani
 *
 * Ccalls for Elisa
 */

#pragma pointer_size long
#include <stdlib.h>
#pragma pointer_size short

#if !defined(CCALL)
#define CCALL(func, subcode, argstring) 
#endif /* CCALL */

/*
 * The format string is a printf-line one, the first thing is the return
 * value, the rest are args.
 */
CCALL(startServer, STARTSERVER, "v")
CCALL(startClient, "STARTCLIENT", "v")
CCALL(callServer, "CALLSERVER", "iii");

CCALL(InitClient, "INITCLIENT", "iis");
CCALL(InitServer, "INITSERVER", "vi"); 
CCALL(CallServer, "CALLSERVER2", "iiipi");
CCALL(CheckWithServer, "CHECKWITHSERVER", "bi");
CCALL(ServerGetStatus, "SERVERGETSTATUS", "ii");
CCALL(ServerGetNumberOfParameters, "SGETNUMPARAMS", "iii");
CCALL(ServerGetParameter, "SGETPARAM", "iiii");
CCALL(RunClient, "RUNCLIENT", "iiipi");
CCALL(ClientGetNumberOfParameters, "CGETNUMPARAMS", "iii");
CCALL(ClientGetParameter, "CGETPARAM", "iiii");

CCALL(Replying, "ASKING", "vs");
CCALL(Tester, "TESTER", "v");
