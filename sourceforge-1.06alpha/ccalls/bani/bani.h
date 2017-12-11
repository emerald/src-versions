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
