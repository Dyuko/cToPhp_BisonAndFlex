/*Código con errores comunes que el traductor debe detectar*/
#include <stdio.h>
int main() {
    int n=100, i;
    unsigned long long fact = 1;
    if (n < 0)
        return 0    //Error: falta ;
    else {
        for (i = 1; i <= n; ++i) {
            fact *= i;
            //Error: falta }
    }
    return 0;
}