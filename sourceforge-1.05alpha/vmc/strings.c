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

char *replaceSuffix(filename, oldsx, newsx)
char *filename, *oldsx, *newsx;
{
  int flen, olen, nlen, i;
  char *answer;
  extern char *malloc();

  if (oldsx == 0) oldsx = "";
  if (newsx == 0) newsx = "";

  flen = strlen(filename);
  olen = strlen(oldsx);
  nlen = strlen(newsx);
  
  i = flen - olen;
  if (i > 0 && filename[i-1] != '/' && !strncmp(&filename[i], oldsx, olen)) {
    flen -= olen;
  }
  answer = malloc(flen + nlen + 1);
  sprintf(answer, "%.*s%s", flen, filename, newsx);
  return answer;
}

char *findFileName(name)
char *name;
{
  char *answer, *malloc();
  int i;

  for (i = strlen(name)-1; i >= 0; i--) {
    if (name[i] == '/') break;
  }
  answer = malloc(strlen(name) - i + 1);
  sprintf(answer, "%s", &name[i+1]);
  return answer;
}
