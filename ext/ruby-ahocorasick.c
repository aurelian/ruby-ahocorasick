
//
// (c) 2008, Aurelian Oancea < aurelian at locknet . ro >
//
// Released under MIT-LICENSE
//

#include <ruby.h>
#include "ac.h"

static VALUE sym_id, sym_value, sym_ends_at, sym_starts_at;

VALUE rb_mAhoCorasick;
VALUE rb_cKeywordTree;

#define KeywordTree(obj, kwt_data) {\
  Data_Get_Struct(obj, struct kwt_struct_data, kwt_data);\
}

struct kwt_struct_data {
  AC_STRUCT * tree;
  int last_id;
  int dictionary_size;
  int is_frozen;
};

static VALUE 
rb_kwt_init(VALUE self) { 
  AC_STRUCT * tree;
  struct kwt_struct_data *kwt_data;

  kwt_data = ALLOC(struct kwt_struct_data);
  tree     = ac_alloc();
  DATA_PTR(self) = kwt_data;
  kwt_data->tree            = tree;
  kwt_data->last_id         = 0;
  kwt_data->dictionary_size = 0;
  kwt_data->is_frozen       = 0;
  return self;
}

static VALUE 
rb_kwt_make(VALUE self) { 
  struct kwt_struct_data *kwt_data;
  KeywordTree(self, kwt_data);

  ac_prep( kwt_data->tree );
  kwt_data->is_frozen = 1;
  return self;
}

//
// [{ :id => x, :value => y, :starts_at, :ends_at], [.... }
//
static VALUE
rb_kwt_search(int argc, VALUE *argv, VALUE self) {
  char * result;        // itermediate result
  char * remain;        // returned by ac_search, the remaing text to search
  int lgt, id, ends_at; // filled in by ac_search, the id and length of result
  int starts_at;
  VALUE v_result;  // one result, as hash
  VALUE v_results; // all the results, an array
  VALUE v_search;  // search string, function argument
  struct kwt_struct_data *kwt_data;
  
  // one mandatory argument.
  rb_scan_args(argc, argv, "1", &v_search);
  // it should be string.
  Check_Type(v_search, T_STRING);
  // get the structure
  KeywordTree(self, kwt_data);
  // freeze the tree, if not already frozen
  if(kwt_data->is_frozen == 0) {
    ac_prep( kwt_data->tree );
    kwt_data->is_frozen = 1;
  }
  // prepare the return value
  v_results= rb_ary_new();
  // fail quickly
  if(kwt_data->dictionary_size == 0) 
    return v_results;
  // prepare the search
  ac_search_init(kwt_data->tree, RSTRING( v_search )->ptr, RSTRING( v_search )->len);
  // loop trought the results
  while((remain= ac_search(kwt_data->tree, &lgt, &id, &ends_at)) != NULL) {
    // this is an individual result as a hash
    v_result= rb_hash_new();
    
    rb_hash_aset( v_result, sym_id, INT2FIX(id) );
    rb_hash_aset( v_result, sym_starts_at, INT2FIX( ends_at - lgt - 1 ) );
    rb_hash_aset( v_result, sym_ends_at, INT2FIX( ends_at - 2 ) );

    result = (char*) malloc (sizeof(char)*lgt);
    sprintf( result, "%.*s", lgt, remain);
    rb_hash_aset( v_result, sym_value, rb_str_new(result, lgt) );

    // yield this hash
    if(rb_block_given_p())
      rb_yield(v_result);

    // store in the results array
    rb_ary_push( v_results, v_result );
    free(result);
  }
  // return all the results
  return v_results;
}

static VALUE 
rb_kwt_size(VALUE self) { 
  struct kwt_struct_data *kwt_data;
  KeywordTree(self, kwt_data);

  return INT2FIX(kwt_data->dictionary_size);
}

static VALUE
rb_kwt_add_string(int argc, VALUE *argv, VALUE self) { 
  VALUE v_string, v_id;
  struct kwt_struct_data *kwt_data;
  char * string;
  int id;

  if( rb_scan_args(argc, argv, "11", &v_string, &v_id) ) {
    KeywordTree(self, kwt_data);
    Check_Type(v_string, T_STRING);
    string= RSTRING(v_string)->ptr;
    if(kwt_data->is_frozen == 1) {
      rb_raise(rb_eRuntimeError, "Cannot add `%s\" into a frozen tree.", string);
    }
    if(v_id == Qnil) {
      id = kwt_data->last_id + 1;
    } else if(TYPE(v_id) != T_FIXNUM) {
      rb_raise(rb_eRuntimeError, "Please use a signed 32 bit integer as id, or leave nil to auto-generate one. `%s\" given.", RSTRING(v_id)->ptr);
    } else if(NUM2INT(v_id) <= 0) {
      rb_raise(rb_eRuntimeError, "Please use a signed 32 bit integer as id, or leave nil to auto-generate one. `%d\" given.", NUM2INT(v_id));
    } else {
      id= NUM2INT(v_id);
    }
    kwt_data->last_id= id + 1;
  }

  if( ac_add_string(kwt_data->tree, string, strlen(string), id) == 0 ) {
    rb_raise(rb_eRuntimeError, "Failed to add `%s\", duplicate id `%d\"?", string, id);
  }

  kwt_data->dictionary_size++;
  return self;
}

// TODO: 
//  * use rb_kwt_add_string
//  * use rb_io* to handle the file
static VALUE
rb_kwt_new_from_file(int argc, VALUE *argv, VALUE klass) { 
  struct kwt_struct_data *kwt_data;
  char word[1024];
  int id;
  VALUE self;
  VALUE f_string;
  FILE *dictionary;

  rb_scan_args(argc, argv, "10", &f_string);
 
  id = 0;
  SafeStringValue( f_string );
  self= rb_class_new_instance( 0, NULL, klass );
  KeywordTree( self, kwt_data );

  dictionary = fopen( RSTRING( f_string )->ptr, "r" );
  if(dictionary == NULL) {
    rb_raise(rb_eRuntimeError, "Cannot open `%s\". No such file?", RSTRING(f_string)->ptr);
  }

  while(fgets(word, 1024, dictionary) != NULL) {
    ac_add_string(kwt_data->tree, word, strlen(word)-1, id++);
    kwt_data->dictionary_size++;
  }
  kwt_data->last_id= id+1;
  fclose(dictionary);
  return self;
}

static void
rb_kwt_struct_free(struct kwt_struct_data * kwt_data)
{
  ac_free(kwt_data->tree);
}

static VALUE
rb_kwt_struct_alloc(VALUE klass)
{
  return Data_Wrap_Struct(klass, 0, rb_kwt_struct_free, 0);
}

/*
 *
 */
void Init_ahocorasick() {
  rb_mAhoCorasick = rb_define_module("AhoCorasick");
  rb_cKeywordTree = rb_define_class_under(rb_mAhoCorasick, "KeywordTree", rb_cObject);
  
  rb_define_alloc_func(rb_cKeywordTree, rb_kwt_struct_alloc);

  rb_define_method(rb_cKeywordTree, "initialize", rb_kwt_init, 0);
  rb_define_method(rb_cKeywordTree, "size", rb_kwt_size, 0);
  rb_define_method(rb_cKeywordTree, "make", rb_kwt_make, 0);
  rb_define_method(rb_cKeywordTree, "add_string", rb_kwt_add_string, -1);
  rb_define_method(rb_cKeywordTree, "search", rb_kwt_search, -1);
  rb_define_alias(rb_cKeywordTree, "<<", "add_string");
  rb_define_singleton_method(rb_cKeywordTree, "from_file", rb_kwt_new_from_file, -1);

  sym_id= ID2SYM(rb_intern("id"));
  sym_value= ID2SYM(rb_intern("value"));
  sym_ends_at= ID2SYM( rb_intern("ends_at") );
  sym_starts_at= ID2SYM( rb_intern("starts_at") );

}

