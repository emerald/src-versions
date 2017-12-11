extern void TimerInit(void);
extern void afterTime(struct timeval t, void (*cb)(void *), void *arg);
extern void checkForTimeouts(void);
extern struct timeval nextWakeup(void);
extern struct timeval TimeMinus(struct timeval a, struct timeval b);
extern struct timeval TimePlus(struct timeval a, struct timeval b);
extern int TimeLess(struct timeval a, struct timeval b);
