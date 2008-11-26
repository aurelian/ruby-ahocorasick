require "mkmf"

# $CFLAGS << " -O3 -Wall -Wextra -Wcast-qual -Wwrite-strings -Wconversion -Wmissing-noreturn -Winline"

dir_config("ahocorasick")

create_makefile("ahocorasick")

