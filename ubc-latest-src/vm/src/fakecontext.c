struct savearea {
  int a, b, c, d, e, f, g, h, i, j, k, l, m;
  int n, o, p, q, r, s, t, u, v, w, x, y, z;
};

void startNewProc(void (*f)(), void *sp)
{
  int x = (int)sp + 1;
  f();
  junk(x);
}

void returnToProc(struct savearea *ts)
{
  int a, b, c, d, e, f, g, h, i, j, k, l, m;
  int n, o, p, q, r, s, t, u, v, w, x, y, z;
  a = ts->a;
  b = ts->b;
  c = ts->c;
  d = ts->d;
  e = ts->e;
  f = ts->f;
  g = ts->g;
  h = ts->h;
  i = ts->i;
  j = ts->j;
  k = ts->k;
  l = ts->l;
  m = ts->m;
  n = ts->n;
  o = ts->o;
  p = ts->p;
  q = ts->q;
  r = ts->r;
  s = ts->s;
  t = ts->t;
  u = ts->u;
  v = ts->v;
  w = ts->w;
  x = ts->x;
  y = ts->y;
  z = ts->z;
  junk2(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z);
}

int saveProcContext(struct savearea *ts)
{
  int a, b, c, d, e, f, g, h, i, j, k, l, m;
  int n, o, p, q, r, s, t, u, v, w, x, y, z;
  
  ts->a = a;
  ts->b = b;
  ts->c = c;
  ts->d = d;
  ts->e = e;
  ts->f = f;
  ts->g = g;
  ts->h = h;
  ts->i = i;
  ts->j = j;
  ts->k = k;
  ts->l = l;
  ts->m = m;
  ts->n = n;
  ts->o = o;
  ts->p = p;
  ts->q = q;
  ts->r = r;
  ts->s = s;
  ts->t = t;
  ts->u = u;
  ts->v = v;
  ts->w = w;
  ts->x = x;
  ts->y = y;
  ts->z = z;
}

int foo()
{
  return 17;
}
