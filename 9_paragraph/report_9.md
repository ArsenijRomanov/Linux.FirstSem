# Отчёт №9

## Цель работы
- Освоить работу с системными вызовами через функции-обёртки libc и универсальную функцию `syscall`.
- На практике использовать `fork`/`exec`/`wait` для запуска команды в дочернем процессе.
- Получить доступ к переменным среды через глобальную переменную `environ`.
- Использовать `clone` и `sethostname` для изоляции имени хоста в дочернем процессе.

## Среда выполнения
- ОС: Ubuntu
- Компилятор: `gcc`
- Инструменты: `strace` (для анализа, опционально)

---

## 1) Системные вызовы: `getpid()` и `syscall(SYS_getpid)`

### Код решения
```c
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
```

### Сборка и запуск
```bash
gcc -Wall -Wextra -O2 syscalls.c -o syscalls
./syscalls
```

Ожидаемый результат: значения PID, полученные через `getpid()` и через `syscall(SYS_getpid)`, совпадают.

---

## 2) Дочерние процессы: `fork()` + `execlp()` + `wait()`

### Код решения
```c
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
```

### Сборка и запуск
```bash
gcc -Wall -Wextra -O2 child_processes.c -o child_processes
./child_processes
```

В дочернем процессе запускается команда:
```bash
expr 2 + 2 * 2
```
Ожидаемый вывод `expr` — `6` (так как `*` имеет приоритет над `+`).

---

## 3) Переменные среды: вывод переменных, имя которых содержит `L`

### Код решения
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern char **environ;

int has_l(char *str)
{

	while (*str != '\0' && *str != '=')
	{
		if (*str == 'L')
			return 1;
		++str;
	}

	return 0;
}

int main()
{
	for (char **env = environ; *env != NULL; env++)
	{
		char *var = *env;

		if (has_l(var))
			printf("%s\n", var);
	}

	return 0;
}
```

### Сборка и запуск
```bash
gcc -Wall -Wextra -O2 environmental_variables.c -o envvars
./envvars
```

Программа проходит по `environ` и выводит только те переменные, у которых **в имени (до символа `=`)** встречается буква `L`.

---

## 4) Аргументы и пространства имён: `clone()` + `sethostname()` + `gethostname()`

### Код решения
```c
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
	const char *name = (const char *)ptr;
	sethostname(name, strlen(name));

	char hostname[256];
	gethostname(hostname, sizeof(hostname));
	printf("Child proccess: %s\n", hostname);

	return 0;
}

int main(int argc, char **argv)
{
	size_t stack_size = 1024 * 10;
	char *child_stack = malloc(stack_size);

	pid_t pid = clone(child_main, child_stack + stack_size - 100,
					  CLONE_NEWUTS | CLONE_NEWUSER | SIGCHLD, argv[1]);

	char hostname[256];
	gethostname(hostname, sizeof(hostname));
	printf("Parent proccess: %s\n", hostname);

	int status;
	wait(&status);

	free(child_stack);

	return 0;
}
```

### Сборка и запуск
```bash
gcc -D_GNU_SOURCE -Wall -Wextra -O2 arguments_and_namespaces.c -o namespaces
./namespaces spicy
```

Программа создаёт дочерний процесс через `clone()` и в дочернем процессе вызывает `sethostname()`, затем в обоих процессах печатает результат `gethostname()`.

---

## Вывод
Были реализованы примеры работы с системными вызовами Linux:
- сравнение результата `getpid()` и `syscall(SYS_getpid)`;
- создание дочернего процесса и запуск внешней команды через `execlp`;
- чтение переменных среды через `environ`;
- создание изолированного пространства имён в дочернем процессе и изменение hostname.
