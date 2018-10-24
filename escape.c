/* escape for C */
#include<stdio.h>
int main(){
    int c;
    while((c=getchar())!=EOF){
        switch(c){
            case '\n':
                putchar('\\');
                putchar('n');
                break;
            case '\t':
                putchar('\\');
                putchar('t');
                break;
            case '\a':
                putchar('\\');
                putchar('a');
                break;
            case '\b':
                putchar('\\');
                putchar('b');
                break;
            case '\f':
                putchar('\\');
                putchar('f');
                break;
            case '\r':
                putchar('\\');
                putchar('r');
                break;
            case '\v':
                putchar('\\');
                putchar('v');
                break;
            case '\\':
                putchar('\\');
                putchar('\\');
                break;
            case '\"':
                putchar('\\');
                putchar('\"');
                break;
            default:
                /*  This is not a special character, so just copy it  */
                putchar(c);
        }
    }
    return 0;
}
