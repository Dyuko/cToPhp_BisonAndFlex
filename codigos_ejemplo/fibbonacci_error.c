/*Código con errores comunes que el traductor debe detectar*/
#include <stdio.h>
int main() {
    int i, n=100, t1 = 0, t2 = 1, nextTerm;
    for i = 1; i <= n; ++i) {   //Error: falta (
        nextTerm = t1 + t2      //Error: falta ;
        t1 = t2;
        t2 = nextTerm;
    //Error: falta }
    return 0;
}