#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
// Optional: use these functions to add debug or error prints to your application
#define DEBUG_LOG(msg,...)
//#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{
    struct thread_data* thread_func_args = (struct thread_data*) thread_param;
    sleep(thread_func_args->wait_to_obtain_ms/1000);
    int rc = pthread_mutex_lock(thread_func_args->mutex);
	if(rc != 0)
	{
		ERROR_LOG("Error locking the mutex with code %d", rc);
		thread_func_args->thread_complete_success=false;
		return thread_param;
	}
    sleep(thread_func_args->wait_to_release_ms/1000);
    rc = pthread_mutex_unlock(thread_func_args->mutex);
	if(rc != 0)
	{
		ERROR_LOG("Error unlocking the mutex with code %d ", rc);
		thread_func_args->thread_complete_success=false;
		return thread_param;
	}
    thread_func_args->thread_complete_success = true;
    return thread_param;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    
    struct thread_data *thread_params = malloc(sizeof(struct thread_data));
    if(thread_params == NULL)
	{
		ERROR_LOG("memory allocation failed ");
		return false;
	}
    thread_params->wait_to_obtain_ms=wait_to_obtain_ms;
    thread_params->wait_to_release_ms=wait_to_release_ms;
    thread_params->mutex=mutex;
    thread_params->thread_complete_success =false;
    int rc = pthread_create(thread,NULL,threadfunc,(void*)thread_params);
    if(rc != 0)
	{
		ERROR_LOG("Thread creation failed with code %d" , rc);
		return false;
	}
		return true;
    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */
    
}

