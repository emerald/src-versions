extern char *getenv(char *);

char *mgetenv(char *key)
{
  return getenv(key);
}

#include <sys/types.h>
#include <dirent.h>
char *mreaddir(DIR *dirp)
{
  struct dirent *de;
  de = readdir(dirp);
  if (de) return de->d_name; else return 0;
}
