/* comment me!
 */

#ifndef _EMERALD_TRACE_H
#define _EMERALD_TRACE_H

extern int
  traceallocate,
  traceassign,
  traceatctsort,
  tracebuiltins,
  tracecall,
  traceccalls,
  tracecheckpoint,
  traceconform,
  traceconformfailure,
  tracecopy,
  tracectinfo,
  tracedbm,
  tracedebug,
  tracedebuginfo,
  tracedelay,
  tracedoto,
  traceemit,
  traceemitmove,
  traceenvironment,
  tracefindct,
  tracefold,
  tracegraph,
  tracehandler,
  tracehelp,
  traceimports,
  traceindex,
  traceinitiallies,
  traceinterpret,
  traceinvoccache,
  tracekernel,
  traceknowct,
  traceknowlocal,
  traceknowmanifest,
  tracegenerate,
  tracelinenumber,
  tracelocals,
  tracemanifest,
  tracemap,
  tracematchat,
  tracememory,
  tracemessage,
  traceoid,
  tracepasses,
  traceprimitive,
  traceprocess,
  tracerecoveries,
  tracerelocation,
  tracescc,
  tracesys,
  tracetempl,
  tracetempreg,
  tracetempstack,
  tracetrans,
  tracestreams,
  tracerinvoke,
  tracetypecheck,
  tracegaggle,
  tracedistgc,
  tracelocate,
  tracedist,
  traceunavailable,
  tracefailure,
  tracex,
  traceT
;

extern void TraceInit(void);
extern void TraceFin(void);
extern void SetTraceFile(char *);
extern void SetTraceBufferSize(int);
extern void traceTS(int);
#ifdef STDARG_WORKS
extern void ftrace(char *, ...);
#else
extern void ftrace();
#endif

#ifdef lint
#   define TRACING(t, level) \
	(level)
#   define IFTRACE(t, level) \
	if (level)
#   define TRACE(t, level, args) \
	if (level) { \
	  traceTS(level); \
	  ftrace args; \
	}
#else /* !lint */
#if defined(NTRACE)
#   define IFTRACE(t, level) if (0)
#   define TRACING(t, level) 0
#   define TRACE(t, level, args)
#else /* !NTRACE */
#if (defined(__ANSI__) || defined(__STDC__) || defined(WIN32)) && !defined(aegis)
#   define IFTRACE(t, level) \
	if (trace##t >= (level))
#   define TRACING(t, level) \
	(trace##t >= (level))
#   define TRACE(t, level, args) \
	if (trace##t >= (level)) { \
	  traceTS((level)); \
	  ftrace args; \
	}
#else /* ! ANSI, etc. */
#   define IFTRACE(t, level) \
	if (trace/**/t >= (level))
#   define TRACING(t, level) \
	(trace/**/t >= (level))
#   define TRACE(t, level, args) \
	if (trace/**/t >= (level)) { \
	  traceTS((level)); \
	  ftrace args; \
	}
#endif /* ANSI, etc. */
#endif /* NTRACE */
#endif /* lint */

#endif /* _EMERALD_TRACE_H */
