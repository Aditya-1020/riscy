int main() {
    volatile int a = 5;
    volatile int b = 7;
    volatile int c;

    c = a + b;       // test ALU add
    c = c - a;       // test ALU sub
    c = c ^ b;       // test ALU xor
    c = c << 1;      // test shift
    if (c > 10) {    // test branch/jump
        c = c + 1;
    } else {
        c = c - 1;
    }

    return c;        // final value in a register
}
