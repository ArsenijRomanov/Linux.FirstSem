#include <stdio.h>

#if defined(USE_GPU) && defined(USE_FLOAT)
void process()
{
	printf("USE_GPU and USE_FLOAT\n");
}
#elif defined(USE_GPU) && !defined(USE_FLOAT)
void process()
{
	printf("USE_GPU\n");
}
#elif !defined(USE_GPU) && defined(USE_FLOAT)
void process()
{
	printf("USE_FLOAT\n");
}
#else
void process()
{
	printf("None\n");
}
#endif

int main()
{
	process();
	return 0;
}