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
