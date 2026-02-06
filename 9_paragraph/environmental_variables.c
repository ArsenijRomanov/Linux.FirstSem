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
