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

/****************************************************************************
 File     : init.h
 Date     : 08-11-92
 Author   : Mark Immel

 Contents : Various Initialization Routines

 Modifications
 -------------

*****************************************************************************/

#ifndef _EMERALD_INIT_H
#define _EMERALD_INIT_H

extern void MessageInit(void);
extern void OIDToObjectInit(void);
extern void OpoidsInit(void);
extern void ReadInit(void);
extern void SigInit(void);
extern void CodeMessageInit(void);

#endif /* _EMERALD_INIT_H */
