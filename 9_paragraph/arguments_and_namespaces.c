#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sched.h>
#include <string.h>

int child_main(void *ptr)
{
	const char *new_hostname = "spicy";
	sethostname(new_hostname, strlen(new_hostname));

	char hostname[256];
	gethostname(hostname, sizeof(hostname));
	printf("Child proccess: %s\n", hostname);

	return 0;
}

int main()
{
	size_t stack_size = 1024 * 10;
	char *child_stack = malloc(stack_size);

	pid_t pid = clone(child_main, child_stack + stack_size - 100,
					  CLONE_NEWUTS | CLONE_NEWUSER | SIGCHLD, NULL);

	char hostname[256];
	gethostname(hostname, sizeof(hostname));
	printf("Parent proccess: %s\n", hostname);

	int status;
	wait(&status);

	free(child_stack);

	return 0;
}
