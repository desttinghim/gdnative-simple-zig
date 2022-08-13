#include "simple.h"
#include <string.h>

struct ClassBuilder *init_class_builder(Api api, void *p_handle,
                                        const char *p_name,
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

void finalize_class(Api api, NativescriptApi nativescript_api,
                    struct ClassBuilder *builder) {
  nativescript_api->godot_nativescript_register_class(
      builder->p_gdnative_handle, builder->p_name, builder->p_base,
      builder->p_create_func, builder->p_destroy_func);
  api->godot_free(builder);
}

void finalize_tool_class(Api api, NativescriptApi nativescript_api,
                         struct ClassBuilder *builder) {
  nativescript_api->godot_nativescript_register_class(
      builder->p_gdnative_handle, builder->p_name, builder->p_base,
      builder->p_create_func, builder->p_destroy_func);
  api->godot_free(builder);
}

void init_class_method(
    NativescriptApi nativescript_api, void *p_handle, const char *class_name,
    const char *method_name, godot_method_attributes attributes,
    GDCALLINGCONV godot_variant (*method)(godot_object *, void *, void *, int,
                                          godot_variant **),
    void *method_data, GDCALLINGCONV void (*free_func)(void *)) {

  godot_instance_method instance_method = {method, method_data, free_func};

  nativescript_api->godot_nativescript_register_method(
      p_handle, class_name, method_name, attributes, instance_method);
}
