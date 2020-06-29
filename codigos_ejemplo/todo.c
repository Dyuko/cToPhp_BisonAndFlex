#include <stdio.h>

int funcion(int x);
int variable_global = 0;

int main()
{
    int vector[10];
    funcion(10);
    vector[0]=0;
    variable_global = vector[0];
}

int funcion(int x)
{
    int i,j;
    for(i=0; i<10; ++i)
    {
        for(j=0; j<10; ++j)
            printf("u.u");
    }
}