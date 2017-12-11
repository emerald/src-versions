#define E_NEEDS_SIGNAL
#define E_NEEDS_SOCKET
#include "system.h"

#include "trace.h"

#include "storage.h"

int timeAdvanced;

#ifdef WIN32
HANDLE alarmWakeup;
DWORD nextWake;
static inline unsigned TOMSEC(struct timeval t)
{
  return t.tv_sec * 1000 + t.tv_usec / 1000;
}

void alarmThread(void *arg)
{
  DWORD status;
  while (1) {
    TRACE(dist, 7, ("alarmThread: waiting for %d", nextWake));
    status = WaitForSingleObject(alarmWakeup, nextWake);
    TRACE(dist, 8, ("alarmThread: woke up status = %d", status));
    switch (status) {
    case WAIT_FAILED:
      perror("WaitForSingleObject");
      break;
    case WAIT_OBJECT_0:
      break;
    case WAIT_TIMEOUT:
      nextWake = INFINITE;
      timeAdvanced = 1;
      break;
    }
  }
}
#else
void sigalarmHandler(int sig)
{
  timeAdvanced = 1;
}
#endif /* WIN32 */


void TimerInit(void)
{
#ifndef WIN32
  extern void establishHandler(int, void (*h)(int));
  establishHandler(SIGALRM, sigalarmHandler);
#else
  HANDLE t;
  DWORD tid;
  alarmWakeup = CreateSemaphore(0, 0, 1, 0);
  if (alarmWakeup == 0) {
    perror("CreateSemaphore");
    die();
  }
  nextWake = INFINITE;
  t = CreateThread(0, 8192, (LPTHREAD_START_ROUTINE)alarmThread, 0, 0, &tid);
  if (t == 0) {
    perror("CreateThread");
    die();
  }
  if (SetThreadPriority(t, THREAD_PRIORITY_ABOVE_NORMAL) == 0) {
    perror("SetThreadPriority");
    die();
  }
#endif /* WIN32 */
}

static void ScheduleAlarm(struct timeval when)
{
#ifndef WIN32
  struct itimerval interval;
  
  if (when.tv_sec < 0 || when.tv_usec < 0 || (when.tv_sec == 0 && when.tv_usec == 0)) {
    timeAdvanced = 1;
  } else {
    /* clock will reset itself at each expiry to this interval     */
    interval.it_interval.tv_sec   = 0;
    interval.it_interval.tv_usec  = 0;

    /* this sets the initial clock interval                        */
    interval.it_value = when;

    /* now start the timer so that it signals with a SIGALRM at expiration */
    if (setitimer(ITIMER_REAL, &interval, NULL) < 0) {
      perror("schedule.setitimer");
    }
  }
#else
  nextWake = TOMSEC(when);
  TRACE(dist, 8, ("ScheduleAlarm, calling release, nextWake = %d", nextWake));
  ReleaseSemaphore(alarmWakeup, 1, 0);
#endif /* WIN32 */
}

static void CancelAlarm(void)
{
#ifndef WIN32
  struct itimerval interval;

  interval.it_interval.tv_sec   = 0;
  interval.it_interval.tv_usec  = 0;

  /* this sets the initial clock interval                        */
  interval.it_value = interval.it_interval;

  /* now cancel the timer */
  if (setitimer(ITIMER_REAL, &interval, NULL) < 0) 
    perror("cancel.setitimer");
#else
  nextWake = INFINITE;
  TRACE(dist, 8, ("CancelAlarm, calling release, nextWake = %d", nextWake));
  ReleaseSemaphore(alarmWakeup, 1, 0);
#endif /* WIN32 */
}

inline struct timeval TimeMinus(struct timeval a, struct timeval b)
{
  struct timeval r;
  if (b.tv_usec > a.tv_usec) {
    r.tv_sec = a.tv_sec - b.tv_sec - 1;
    r.tv_usec = a.tv_usec + 1000000 - b.tv_usec;
  } else {
    r.tv_sec = a.tv_sec - b.tv_sec;
    r.tv_usec = a.tv_usec - b.tv_usec;
  }
  if (r.tv_sec < 0 || r.tv_usec < 0) r.tv_sec = r.tv_usec = 0;
  return r;
}

struct timeval TimePlus(struct timeval a, struct timeval b)
{
  struct timeval r;
  r.tv_usec = a.tv_usec + b.tv_usec;
  r.tv_sec = a.tv_sec + b.tv_sec;
  while (r.tv_usec > 1000000) {
    r.tv_usec -= 1000000;
    r.tv_sec ++;
  }
  return r;
}

int TimeLess(struct timeval a, struct timeval b)
{
  return a.tv_sec < b.tv_sec ||
    (a.tv_sec == b.tv_sec && a.tv_usec <= b.tv_usec);
}

typedef struct TimeList {
  struct TimeList *prev, *next;
  struct timeval when;
  void (*cb)(void *);
  void *arg;
} TimeList;
static TimeList *sleepers;

void afterTime(struct timeval t, void (*cb)(void *), void *arg)
{
  struct timeval now, when;
  TimeList *curr = (TimeList *)vmMalloc(sizeof (*curr)), *prev, *this;
  gettimeofday(&now, 0);

  when = TimePlus(now, t);

  if (TimeLess(when, now)) {
    cb(arg);
  } else {
    curr->when = when;
    curr->cb = cb;
    curr->arg = arg;
    for (prev = 0, this = sleepers; 
	 this && TimeLess(this->when, when);
	 prev = this, this = this->next) ;
    curr->prev = prev;
    curr->next = this;
    if (prev) {
      prev->next = curr;
    } else {
      sleepers = curr;
      ScheduleAlarm(TimeMinus(sleepers->when, now));
    }
    if (this) this->prev = curr;
  }
}

/*
 * This function has to be a little careful to make sure that if a callback
 * function schedules another callback that it works ok.
 */
void checkForTimeouts(void)
{
  TimeList *this;
  struct timeval now;
  int didWakeups = 0;

  gettimeofday(&now, 0);
  while (sleepers && TimeLess(sleepers->when, now)) {
    didWakeups = 1;
    this = sleepers;
    sleepers = this->next;
    if (sleepers) sleepers->prev = 0;

    this->cb(this->arg);
    vmFree((char *)this);
  }
  if (sleepers) {
    ScheduleAlarm(TimeMinus(sleepers->when, now));
  } else {
    CancelAlarm();
  }
}

struct timeval nextWakeup(void)
{
  static struct timeval zero;
  return sleepers ? sleepers->when : zero;
}
