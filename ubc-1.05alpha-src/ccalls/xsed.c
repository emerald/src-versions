/*
 * FILE       : xsed.c
 * CREATOR    : Michael Svendsen, zorgylp@diku.dk, alias = MS
 * OTHERS     :
 * DO WHAT?   : Translate a .va file into a .c file. All instances of
 *              ... (that is 3 dots) will be replaced with a static
 *              number of arguments defined by XTARGSSIZE. If you
 *              change the size of _mxtlocal in the xta.va file
 *              you should change  XTARGSSIZE as well.
 *
 * HISTORY    : 960821 MS : Created
 *
 */

#include <stdio.h>

#define XTARGSSIZE 100

int main() {
  int dots=0,i;
  char c;

  printf("/*\n");
  printf(" * This file is automatically created from the files\n *\n");
  printf(" *      xta.va and xma.va\n *\n");
  printf(" * respectively.\n *\n");
  printf(" * DO NOT EXPECT CHANGES TO BE SEEN IF NOT MADE IN THE .va FILES\n */\n\n");

  printf("/*\n");
  printf(" * The xsed program in the ccalls directory has been used to\n");
  printf(" * compile the .va files into .c files.\n");
  printf(" * See the xsed.c source file for more information.\n");
  printf(" */\n\n");

 

  while ((c=getchar())!=EOF) {
    if (c=='.') {
      dots++;
    } else {
      if (dots) {
        if (dots!=3) {
          while (dots>0) {
            putchar('.');
            dots--;
          }
          putchar(c);
        } else {
          for (i=0;i<(XTARGSSIZE-1);i++)
            printf("\n\t_mxtargs[%d],",i);
          printf("\n\t_mxtargs[%d]",i);
          putchar(c);
          dots=0;
        }
      } else {
        putchar(c);
      }
    }
  }
  return 0;
}
