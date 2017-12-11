int g;

main()
{
  int l;
  long *ll;
  printf("Sizeof int = %d\n", sizeof(int));
  printf("Sizeof long = %d\n", sizeof(long));
  printf("Sizeof char * = %d\n", sizeof(char *));
  printf("Address of global g = %lx\n", &g);
  printf("Address of local l = %lx\n", &l);
  ll = malloc(32);
  *ll = 5;
  ll = (long)ll + 4;
  *ll = 6;
}
