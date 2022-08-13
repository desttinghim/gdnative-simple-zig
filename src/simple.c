#include "simple.h"
#include <string.h>

// GDNative supports a large collection of functions for calling back
// into the main Godot executable. In order for your module to have
// access to these functions, GDNative provides your application with
// a struct containing pointers to all these functions.
const godot_gdnative_core_api_struct *api = NULL;
const godot_gdnative_ext_nativescript_api_struct *nativescript_api = NULL;

// These are forward declarations for the functions we'll be implementing
// for our object. A constructor and destructor are both necessary.
GDCALLINGCONV void *simple_constructor(godot_object *p_instance,
                                       void *p_method_data);
GDCALLINGCONV void simple_destructor(godot_object *p_instance,
                                     void *p_method_data, void *p_user_data);
godot_variant simple_get_data(godot_object *p_instance, void *p_method_data,
                              void *p_user_data, int p_num_args,
                              godot_variant **p_args);

// `gdnative_init` is a function that initializes our dynamic library.
// Godot will give it a pointer to a structure that contains various bits of
// information we may find useful among which the pointers to our API
// structures.
void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *p_options) {
  api = p_options->api_struct;

  // Find NativeScript extensions.
  for (int i = 0; i < api->num_extensions; i++) {
    switch (api->extensions[i]->type) {
    case GDNATIVE_EXT_NATIVESCRIPT: {
      nativescript_api =
          (godot_gdnative_ext_nativescript_api_struct *)api->extensions[i];
    }; break;
    default:
      break;
    };
  };
}

// `gdnative_terminate` which is called before the library is unloaded.
// Godot will unload the library when no object uses it anymore.
void GDN_EXPORT
godot_gdnative_terminate(godot_gdnative_terminate_options *p_options) {
  api = NULL;
  nativescript_api = NULL;
}

// `nativescript_init` is the most important function. Godot calls
// this function as part of loading a GDNative library and communicates
// back to the engine what objects we make available.
void GDN_EXPORT godot_nativescript_init(void *p_handle) {
  nativescript_init();
  // godot_instance_create_func create = {NULL, NULL, NULL};
  // create.create_func = &simple_constructor;

  // godot_instance_destroy_func destroy = {NULL, NULL, NULL};
  // destroy.destroy_func = &simple_destructor;

  // We first tell the engine which classes are implemented by calling this.
  // * The first parameter here is the handle pointer given to us.
  // * The second is the name of our object class.
  // * The third is the type of object in Godot that we 'inherit' from;
  //   this is not true inheritance but it's close enough.
  // * Finally, the fourth and fifth parameters are descriptions
  //   for our constructor and destructor, respectively.
  // nativescript_api->godot_nativescript_register_class(
  //    p_handle, "Simple", "Reference", create, destroy);

  // godot_instance_method get_data = {NULL, NULL, NULL};
  // get_data.method = &simple_get_data;

  // godot_method_attributes attributes = {GODOT_METHOD_RPC_MODE_DISABLED};

  // We then tell Godot about our methods by calling this for each
  // method of our class. In our case, this is just `get_data`.
  // * Our first parameter is yet again our handle pointer.
  // * The second is again the name of the object class we're registering.
  // * The third is the name of our function as it will be known to GDScript.
  // * The fourth is our attributes setting (see godot_method_rpc_mode enum in
  //   `godot_headers/nativescript/godot_nativescript.h` for possible values).
  // * The fifth and final parameter is a description of which function
  //   to call when the method gets called.
  // nativescript_api->godot_nativescript_register_method(
  //    p_handle, "Simple", "get_data", attributes, get_data);
}

// In our constructor, allocate memory for our structure and fill
// it with some data. Note that we use Godot's memory functions
// so the memory gets tracked and then return the pointer to
// our new structure. This pointer will act as our instance
// identifier in case multiple objects are instantiated.
GDCALLINGCONV void *simple_constructor(godot_object *p_instance,
                                       void *p_method_data) {
  user_data_struct *user_data = api->godot_alloc(sizeof(user_data_struct));
  strcpy(user_data->data, "World from GDNative!");

  return user_data;
}

// The destructor is called when Godot is done with our
// object and we free our instances' member data.
GDCALLINGCONV void simple_destructor(godot_object *p_instance,
                                     void *p_method_data, void *p_user_data) {
  api->godot_free(p_user_data);
}

// Data is always sent and returned as variants so in order to
// return our data, which is a string, we first need to convert
// our C string to a Godot string object, and then copy that
// string object into the variant we are returning.
godot_variant simple_get_data(godot_object *p_instance, void *p_method_data,
                              void *p_user_data, int p_num_args,
                              godot_variant **p_args) {
  godot_string data;
  godot_variant ret;
  user_data_struct *user_data = (user_data_struct *)p_user_data;

  api->godot_string_new(&data);
  api->godot_string_parse_utf8(&data, user_data->data);
  api->godot_variant_new_string(&ret, &data);
  api->godot_string_destroy(&data);

  return ret;
}

struct ClassBuilder *init_class_builder(void *p_handle, const char *p_name,
                                        const char *p_base) {
  struct ClassBuilder *class_builder =
      api->godot_alloc(sizeof(struct ClassBuilder));
  *class_builder = (struct ClassBuilder){
      .p_gdnative_handle = p_handle,
      .p_name = p_name,
      .p_base = p_base,
      .p_create_func = {NULL, NULL, NULL},
      .p_destroy_func = {NULL, NULL, NULL},
  };
  return class_builder;
}

void init_class_constructor(struct ClassBuilder *builder,
                            GDCALLINGCONV void *(*create_func)(godot_object *,
                                                               void *),
                            void *method_data,
                            GDCALLINGCONV void (*free_func)(void *)) {
  builder->p_create_func = (godot_instance_create_func){
      create_func,
      method_data,
      free_func,
  };
}

void init_class_destructor(struct ClassBuilder *builder,
                           GDCALLINGCONV void (*destroy_func)(godot_object *,
                                                              void *, void *),
                           void *method_data,
                           GDCALLINGCONV void (*free_func)(void *)) {
  builder->p_destroy_func = (godot_instance_destroy_func){
      destroy_func,
      method_data,
      free_func,
  };
}

void finalize_class(struct ClassBuilder *builder) {
  nativescript_api->godot_nativescript_register_class(
      builder->p_gdnative_handle, builder->p_name, builder->p_base,
      builder->p_create_func, builder->p_destroy_func);
  api->godot_free(builder);
}

void finalize_tool_class(struct ClassBuilder *builder) {
  nativescript_api->godot_nativescript_register_class(
      builder->p_gdnative_handle, builder->p_name, builder->p_base,
      builder->p_create_func, builder->p_destroy_func);
  api->godot_free(builder);
}

void init_class_method(
    void *p_handle, const char *class_name, const char *method_name,
    godot_method_attributes attributes,
    GDCALLINGCONV godot_variant (*method)(godot_object *, void *, void *, int,
                                          godot_variant **),
    void *method_data, GDCALLINGCONV void (*free_func)(void *)) {

  godot_instance_method instance_method = {method, method_data, free_func};

  nativescript_api->godot_nativescript_register_method(
      p_handle, class_name, method_name, attributes, instance_method);
}
