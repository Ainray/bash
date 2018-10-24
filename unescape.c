/* escape for C */
#include<stdio.h>
int main(){
    int c;
    while((c=getchar())!=EOF){
        if(c=='\\'){
            if((c=getchar())!=EOF){
                switch(c){
                    case 'n':
                        putchar('\n');
                        break;
                    case 't':
                        putchar('\t');
                        break;
                    case 'a':
                        putchar('\a');
                        break;
                    case 'b':
                        putchar('\b');
                        break;
                    case 'f':
                        putchar('\f');
                        break;
                    case 'r':
                        putchar('\r');
                        break;
                    case 'v':
                        putchar('\v');
                        break;
                    case '\\':
                        putchar('\\');
                        break;
                    case '"':
                        putchar('\"');
                        break;
                    default:
                        /*  This is not a special character, so just copy it  */
                        break;
                }
            }
            else{
                putchar('\\');
                putchar(c);
            }
        }
        else
            putchar(c);
    }
    return 0;
}
