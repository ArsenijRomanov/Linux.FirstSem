#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>

int main()
{
	int pid = getpid();
	printf("PID via getpid: %d\n", pid);

	int pid_syscall = syscall(SYS_getpid);
	printf("PID via syscall: %d\n", pid_syscall);

	if (pid == pid_syscall)
		printf("PIDs are equal\n");
	else
		printf("PIDs are not equal\n");

	return 0;
}