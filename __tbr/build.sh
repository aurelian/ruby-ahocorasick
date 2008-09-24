#!/bin/sh

gcc test.c -o dl-test -I./ext/ -L./ext/ -lasick

# gcc -static test.c -I./ext -L./ext -lasick -o st-test

