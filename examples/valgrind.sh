#!/bin/sh
valgrind -v --tool=memcheck --num-callers=100 --track-fds=yes --error-limit=no --partial-loads-ok=yes --undef-value-errors=no --leak-check=full --show-reachable=no --freelist-vol=100000000 --malloc-fill=6D --free-fill=66 ruby -w examples/valgrind.rb

