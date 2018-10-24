/* print limits of char, short, int, and long variables */
#include<float.h>
#include<limits.h>
#include<stdio.h>

int main(){
    printf("Constants in <limits.h>:\n");
    printf("Bits in Char, CHAR_BIT=%d\n", CHAR_BIT);
    printf("Minimum value of char, CHAR_MIN=%d\n", CHAR_MIN);
    printf("Maximum value of char, CHAR_MAX=%d\n", CHAR_MAX);
    printf("Minimum value of signed char, SCHAR_MIN=%d\n", SCHAR_MIN);
    printf("Maximum value of signed char, SCHAR_MAX=%d\n", SCHAR_MAX);
    printf("Minimum value of int, INT_MIN=%d\n", INT_MIN);
    printf("Maximum value of int, INT_MAX=%d\n", INT_MAX);
    printf("Minimum value of long, LONG_MIN=%ld\n", LONG_MIN);       /* RB */
    printf("Maximum value of long, LONG_MAX=%ld\n", LONG_MAX);       /* RB */
    printf("Minimum value of short, SHRT_MIN=%d\n", SHRT_MIN);
    printf("Maximum value of short, SHRT_MAX=%d\n", SHRT_MAX);
    printf("Maximum value of char, UCHAR_MAX=%u\n", UCHAR_MAX);  /* SF */
    printf("Maximum value of char, ULONG_MAX=%lu\n", ULONG_MAX); /* RB */
    printf("Maximum value of char, UINT_MAX=%u\n", UINT_MAX);    /* RB */
    printf("Maximum value of char, USHRT_MAX=%u\n", USHRT_MAX); /* SF */
    printf("Constants in <float.h>:\n");
    printf("Radix of exponent, FLT_RADIX=%d\n",FLT_RADIX);
    printf("Floating-point rounding mode for addition, FLT_ROUNDS=%d\n",FLT_ROUNDS);
    printf("Decimal digits of single precision, FLT_DIG=%d\n",FLT_DIG);
    printf("Smallest float number of x such that 1.0+x !=1.0, FLT_EPSILON=%e\n",FLT_EPSILON);
    printf("Number of base FLT_RADIX in mantissa, FLT_MANT_DIG=%d\n",FLT_MANT_DIG);
    printf("Maximum floating-point number, FLT_MAX=%e\n",FLT_MAX);
    printf("Maximum n such that FLT_RADIX^(n-1) is representable with single precision, FLT_MAX_EXP=%d\n",FLT_MAX_EXP);
    printf("Minimum normalized single floating-point number, FLT_MIN=%e\n",FLT_MIN);
    printf("Minimum n such that 10^n is a normalized number, FLT_MIN_EXP=%d\n",FLT_MIN_EXP);
    printf("Decimal digits of double precision, DBL_DIG=%d\n",DBL_DIG);
    printf("Smallest double floating-point number of x such that 1.0+x !=1.0, DBL_EPSILON=%e\n",DBL_EPSILON);
    printf("Number of base FLT_RADIX in mantissa, DBL_MANT_DIG=%d\n", DBL_MANT_DIG);
    printf("Maximum double floating-point number, DBL_MAX=%e\n", DBL_MAX);
    printf("Maximum n such that FTL_RADIX^(n-1) is representable with double precision, DBL_MAX_EXP=%d\n", DBL_MAX_EXP);
    printf("Minimum normalized double floating-point number, DBL_MIN=%e\n", DBL_MIN);
    printf("Minimum n such that 10^n is a normalized number, DBL_MIN_EXP=%d\n", DBL_MIN_EXP);

    return 0;
}
