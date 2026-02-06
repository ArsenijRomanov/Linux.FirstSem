#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

int main()
{
	pid_t pid = fork(); // в дочернем процессе вернет 0

	if (pid == -1)
	{
		perror("fork");
		exit(1);
	}

	if (pid == 0)
	{
		execlp("expr", "expr", "2", "+", "2", "*", "2", (char *)NULL);
		perror("execlp");
		exit(1);
	}
	else
	{
		int status;
		wait(&status);
		if (WIFEXITED(status))
			printf("The child process ended with code: %d\n", WEXITSTATUS(status));
		else
			printf("The child process ended with error\n");
	}

	return 0;
}
