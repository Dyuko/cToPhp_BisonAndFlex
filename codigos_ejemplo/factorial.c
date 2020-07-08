#include <stdio.h>
int main() {
    int n=100, i;
    unsigned long long fact = 1;
    // shows error if the user enters a negative integer
    if (n < 0)
        return 0;
    else {
        for (i = 1; i <= n; ++i) {
            fact *= i;
        }
    }
    return 0;
}