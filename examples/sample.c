//
// Getting started with Aho-Corasick from Strmat
//
// lasick Makefile:
//
// --
// ac.o :
//   gcc -c -fPIC -shared ac.c
// libasick : ac.o
//   gcc -shared -Wl,-soname,libasick.so -o libasick.so.1.0.1
//   ar rcs libasick.a ac.o
// clean : 
//   rm -rf *.o *.a *.so* *.dylib*
// --
//
// Compile this stuff - asick is the library name, generated with the above Makefile :)
//
//   gcc sample.c -o ac-sample -I../ext/ -L../ext/ -lasick
//

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "ac.h"

int main(int argc, char *argv[]) {
  char * search;
  char * remain;
  char * result;
  char word[1024];

  FILE *dictionary;
  FILE *input;
  int lgt, id, n, i;

  AC_STRUCT * tree;
  
  input= fopen(argv[1], "r");

  if(input == NULL) {
    search= argv[1];
  } else {
    long lSize;
    fseek (input , 0 , SEEK_END);
    lSize= ftell (input);
    rewind(input);
    search = (char*) malloc (sizeof(char)*lSize);
    if (search == NULL) { fputs ("Error: Memory error",stderr); exit(-2); }
    fread(search, 1, lSize-1, input);
  }

  dictionary= fopen("../spec/data/dictionary.txt", "r");

  if(dictionary == NULL) {
    printf("Error: can't open file.\n");
    return -1;
  }

  tree= ac_alloc();

  // start counting from 1
  n= 1;
  
  printf("==> building dictionary ...");

  while(fgets(word, 1024, dictionary) != NULL) {
    // strip \n
    ac_add_string(tree, word, strlen(word)-1, n++);
  }

  printf("%d entries added.\n",n);

  ac_prep(tree);

  printf("==> input text [%d]:\n--\n%s\n--\n", strlen(search), search);

  ac_search_init(tree, search, strlen(search) );
  
  while((remain= ac_search(tree, &lgt, &id)) != NULL) {
    printf("`%d'", remain[lgt+1]);
    result = (char*) malloc (sizeof(char)*lgt);
    sprintf( result, "%.*s", lgt, remain);
    // result: should read first lgt chars from remain.
    printf("==> result: lenght=> %d, id=> %d [%s]\n", lgt, id, result);
    free(result);
  }

  ac_free(tree);
  fclose(dictionary);
  free(search);

  return 0;
}

