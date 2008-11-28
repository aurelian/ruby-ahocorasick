
//
// (c) 2008, Aurelian Oancea < oancea at gmail dot com >
//
// Released under MIT-LICENSE
//

//
// TODO: new methods?
//
//  * kwt[id] = word
//  * kwt.from_file (class instance method)
//
//  * kwt.find_each ("str") {|r| .. }
//  * kwt.find_first("str")
//  * kwt.find_all  ("str")
//
// TODO: change last_id and dictionary_size to long
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

// int
// rb_add_string(struct kwt_struct_data *kwt, char *word, int size, int id) {
//   if(ac_add_string( kwt->tree, word, size, id ) == 0)
//     return 0;
//   kwt->dictionary_size++;
//   kwt->last_id= id+1;
//   return 1;
// }

/*
 * call-seq: initialize
 *
 * Creates a new KeywordTree
 *
 *   require 'ahocorasick'
 *   kwt = Ahocorasick::KeywordTree.new
 *
 */
static VALUE 
rb_kwt_init(VALUE self)
{ 
  AC_STRUCT * tree;
  struct kwt_struct_data *kwt_data;

  kwt_data = ALLOC(struct kwt_struct_data);
  tree     = ac_alloc();
  DATA_PTR(self) = kwt_data;
  kwt_data->tree            = tree;
  kwt_data->last_id         = 1;
  kwt_data->dictionary_size = 0;
  kwt_data->is_frozen       = 0;
  return self;
}

/*
 * Document-method: make
 * call-seq: make
 *
 * It freezes the current KeywordTree.
 *
 * ==== Note: This method is called internally by search
 *
 *   require 'ahocorasick'
 *   
 *   kwt = Ahocorasick::KeywordTree.new
 *
 *   kwt.add_string("one")
 *   kwt.add_string("two")
 *   kwt.make()
 */
static VALUE 
rb_kwt_make(VALUE self)
{ 
  struct kwt_struct_data *kwt_data;
  KeywordTree(self, kwt_data);

  if(kwt_data->is_frozen == 1)
    return Qtrue;
  
  if(ac_prep( kwt_data->tree ) == 1) {
    kwt_data->is_frozen = 1;
    return Qtrue;
  }

  rb_raise(rb_eRuntimeError, "Cannot freeze the tree");
}

/*
 * Document-method: find_all
 * call-seq: find_all
 *
 * Search the current tree.
 *
 * It returns an array on hashes, e.g.
 *
 *   [ { :id => int, :value => int, :starts_at => int, :ends_at => int}, { ... } ]
 * 
 * Returns an empty array when the search didn't return any result.
 *
 *   # assuming a valid KeywordTree kwt object:
 *   kwt.add_string("one")
 *   kwt.add_string("two")
 *
 *   kwt.search( "moved two times already" ).each  do | result |
 *     result[:id] # => 2
 *     result[:ends_at] # => 9
 *     result[:starts_at] # => 6
 *     result[:value] # => two
 *   end # => 1
 *
 */
static VALUE
rb_kwt_find_all(int argc, VALUE *argv, VALUE self)
{
  char * remain;        // returned by ac_search, the remaing text to search
  int lgt, id, ends_at; // filled in by ac_search: the length of the result, the id, and starts_at/ends_at position
  VALUE v_result;  // one result, as hash
  VALUE v_results; // all the results, an array

  VALUE v_search;  // search string, function argument
  struct kwt_struct_data *kwt_data;
  
  // one mandatory argument.
  rb_scan_args(argc, argv, "1", &v_search);
  // it should be string.
  Check_Type(v_search, T_STRING);
  v_search= StringValue( v_search );

  // get the structure
  KeywordTree(self, kwt_data);
  // freeze the tree, if not already
  if(kwt_data->is_frozen == 0) {
    if(ac_prep( kwt_data->tree ) == 0) 
      rb_raise(rb_eRuntimeError, "Cannot freeze the tree!");
    kwt_data->is_frozen = 1;
  }
  // prepare the return value
  v_results= rb_ary_new();
  // fail quickly and return the empty array
  if(kwt_data->dictionary_size == 0) 
    return v_results;
  // prepare the search
  ac_search_init(kwt_data->tree, StringValuePtr(v_search), (int)NUM2INT(rb_funcall(v_search, rb_intern("length"), 0)));
  // loop trought the results
  while((remain= ac_search(kwt_data->tree, &lgt, &id, &ends_at)) != NULL) {
    // this is an individual result as a hash
    v_result= rb_hash_new();
    rb_hash_aset( v_result, sym_id,        INT2NUM( (long)id ) );
    rb_hash_aset( v_result, sym_starts_at, INT2NUM( (long)(ends_at - lgt - 1) ) );
    rb_hash_aset( v_result, sym_ends_at,   INT2NUM( (long)(ends_at - 1) ) );
    rb_hash_aset( v_result, sym_value, rb_str_new(remain, (long)lgt) );
    rb_ary_push( v_results, v_result );
  }
  // reopen the tree
  kwt_data->is_frozen= 0;
  return v_results;
}

/*
 * Document-method: size
 * call-seq: size
 *
 * Returns the size of this KeywordTree
 *
 *    kwt.add_string("foo")
 *    kwt.add_string("bar")
 *    kwt.size #=> 2
 *
 */ 
static VALUE 
rb_kwt_size(VALUE self)
{ 
  struct kwt_struct_data *kwt_data;
  KeywordTree(self, kwt_data);

  return INT2FIX(kwt_data->dictionary_size);
}

/*
 * Document-method: add_string
 * call-seq: add_string
 *
 * Adds a sequence to this KeywordTree.
 *
 *    kwt.add_string("foo1$21^ 98N3 ba>Z")
 *    kwt << "bar" # using the alias
 * 
 * ==== Note: you can also specify the id, a number between 1 and k
 *
 *    kwt.add_string "bar", 123 # => 123
 *
 * This id should be unique in the context of the current tree.
 *
 * Returns the id of the inserted object.
 *
 *    kwt.add_string("test", 18) # => 18
 *    kwt.add_string("baz") # => 19
 *
 */ 
static VALUE
rb_kwt_add_string(int argc, VALUE *argv, VALUE self)
{ 
  VALUE v_string, v_id;
  struct kwt_struct_data *kwt_data;
  // char * string;
  int id;

  rb_scan_args(argc, argv, "11", &v_string, &v_id);
 
  Check_Type(v_string, T_STRING);
  // string= StringValuePtr(v_string);
  KeywordTree(self, kwt_data);

  if(kwt_data->is_frozen == 1)
    rb_raise(rb_eRuntimeError, "Cannot add `%s\" into a frozen tree.", StringValuePtr(v_string));

  if(v_id == Qnil) {
    id = kwt_data->last_id;
  } else if(TYPE(v_id) != T_FIXNUM) {
    rb_raise(rb_eRuntimeError, "Please use a number from 1 to K as id, or leave nil to auto-generate one. `%s\" given.", StringValuePtr(v_id));
  } else if(NUM2INT(v_id) <= 0) {
    rb_raise(rb_eRuntimeError, "Please use a number from 1 to K as id, or leave nil to auto-generate one. `%d\" given.", NUM2INT(v_id));
  } else {
    id= NUM2INT(v_id);
  }
  if(ac_add_string(kwt_data->tree, StringValuePtr(v_string), (int)NUM2INT(rb_funcall(v_string, rb_intern("length"), 0)), id) == 0)
    rb_raise(rb_eRuntimeError, "Failed to add `%s\", duplicate id `%d\"?", StringValuePtr(v_string), id);

  kwt_data->last_id= id + 1;
  kwt_data->dictionary_size++;
  return INT2FIX(id);
}

/*
 * call-seq: from_file
 *
 * Creates a new KeywordTree and loads the dictionary from a file
 * 
 *    % cat dict0.txt
 *    foo
 *    bar
 *    base
 *     
 *    k= AhoCorasick::KeywordTree.from_file "dict0.txt"
 *    k.search("basement").size # => 1
 *
 */
static VALUE
rb_kwt_new_from_file(int argc, VALUE *argv, VALUE klass)
{ 

  // TODO: 
  //  * use rb_kwt_add_string
  //  * use rb_io* to handle the file

  struct kwt_struct_data *kwt_data;
  char word[1024];
  int id = 0;
  VALUE self;
  VALUE filename;
  FILE *dictionary;

  rb_scan_args(argc, argv, "10", &filename);
  
  SafeStringValue(filename);
  self= rb_class_new_instance( 0, NULL, klass );
  KeywordTree( self, kwt_data );

  dictionary= fopen( StringValuePtr(filename), "r" );
  if(dictionary == NULL)
    rb_raise(rb_eRuntimeError, "Cannot open `%s\". No such file?", StringValuePtr(filename));

  while(fgets(word, 1024, dictionary) != NULL) {
    ac_add_string(kwt_data->tree, word, (int)(strlen(word)-1), id++);
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
 * Blump.
 */
void Init_native() {
  rb_mAhoCorasick = rb_define_module("AhoCorasick");
  rb_cKeywordTree = rb_define_class_under(rb_mAhoCorasick, "KeywordTree", rb_cObject);
  
  rb_define_alloc_func(rb_cKeywordTree, rb_kwt_struct_alloc);

  rb_define_method(rb_cKeywordTree, "initialize", rb_kwt_init, 0);
  rb_define_method(rb_cKeywordTree, "size", rb_kwt_size, 0);
  rb_define_method(rb_cKeywordTree, "make", rb_kwt_make, 0);
  rb_define_method(rb_cKeywordTree, "add_string", rb_kwt_add_string, -1);
  rb_define_alias(rb_cKeywordTree, "<<", "add_string");

  rb_define_method(rb_cKeywordTree, "find_all", rb_kwt_find_all, -1);
  rb_define_alias(rb_cKeywordTree, "search", "find_all");

  rb_define_singleton_method(rb_cKeywordTree, "_from_file", rb_kwt_new_from_file, -1);

  sym_id       = ID2SYM(rb_intern("id"));
  sym_value    = ID2SYM(rb_intern("value"));
  sym_ends_at  = ID2SYM( rb_intern("ends_at") );
  sym_starts_at= ID2SYM( rb_intern("starts_at") );
}

