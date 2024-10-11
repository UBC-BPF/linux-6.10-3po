#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/syscall.h>

int main(int argc, char** argv) {
    if (argc != 2) {
        printf("Example usage: %s rdma://1,192.168.0.12:9400\n", argv[0]);
        return EXIT_FAILURE;
    }
    long rv = syscall(326, argv[1]);
    if (rv != 0) {
        perror("is_session_create");
    }
    return EXIT_SUCCESS;
}
