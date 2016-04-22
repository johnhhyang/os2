#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"
#include "pthread.h"

// Implement your pthreads library here.

/*
int
signal(int signum, void* handler){

  void (*trampoline_addr)() = &trampoline;

  handler = (sighandler_t)handler;
  register_signal_handler(signum, handler, trampoline_addr);
  return 0;
}
*/


/*
	void *(*start_routine) (void*) is what should be clone's 1st argument
	void *arg is clone's 2nd argument
	clone's 3rd argument, *stek, should be allocated here?
*/

#define PAGESIZE (4096)  //Maybe 4092??

int pthread_create(pthread_t *thread, const pthread_attr_t *attr, void *(*start_routine) (void*), void *arg){

	void *mystek = malloc((uint)PAGESIZE*2); //Why do we need the *2?
//zzddhhtjzz/xv6/blob/master
	if((uint)mystek % PAGESIZE){
		mystek += 4096 - ((uint)mystek % PAGESIZE);
	}
	thread->pid = clone(start_routine, arg, mystek);
	return thread->pid;
}

int pthread_join(pthread_t thread, void **retval){

	void *stek;

	join((int)thread.pid, &stek, (void*)retval);

	free(stek);

	return 0;
}

int pthread_exit(void *retval){

	texit(retval);

	return 0;
}


int pthread_mutex_init(pthread_mutex_t *mutex, const pthread_mutex_attr_t *attr){

	int mid = mutex_init();

	//returns the id of the initalized mutex
	return mid;
}


int pthread_mutex_destroy(pthread_mutex_t *mutex){

	mutex_destroy(mutex->mid);
	return 0;
}


int pthread_mutex_lock(pthread_mutex_t *mutex){

	mutex_lock(mutex->mid);
	return 0;
}


int pthread_mutex_unlock(pthread_mutex_t *mutex){

	mutex_unlock(mutex->mid);
	return 0;
}