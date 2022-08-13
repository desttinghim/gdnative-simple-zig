#ifndef SIMPLE_H_
#define SIMPLE_H_

#include <gdnative_api_struct.gen.h>

typedef const godot_gdnative_core_api_struct *Api;
typedef const godot_gdnative_ext_nativescript_api_struct *NativescriptApi;

struct ClassBuilder {
  void *p_gdnative_handle;
  const char *p_name;
  const char *p_base;
  godot_instance_create_func p_create_func;
  godot_instance_destroy_func p_destroy_func;
};

struct ClassBuilder *init_class_builder(Api api, void *p_handle,
                                        const char *p_name, const char *p_base);
void init_class_constructor(struct ClassBuilder *builder,
                            GDCALLINGCONV void *(*create_func)(godot_object *,
                                                               void *),
                            void *method_data,
                            GDCALLINGCONV void (*free_func)(void *));

void init_class_destructor(struct ClassBuilder *builder,
                           GDCALLINGCONV void (*destroy_func)(godot_object *,
                                                              void *, void *),
                           void *method_data,
                           GDCALLINGCONV void (*free_func)(void *));
void finalize_class(Api api, NativescriptApi nativescript_api,
                    struct ClassBuilder *builder);
void finalize_tool_class(Api api, NativescriptApi nativescript_api,
                         struct ClassBuilder *builder);

void init_class_method(
    NativescriptApi nativescript_api, void *p_handle, const char *class_name,
    const char *method_name, godot_method_attributes attributes,
    GDCALLINGCONV godot_variant (*method)(godot_object *, void *, void *, int,
                                          godot_variant **),
    void *method_data, GDCALLINGCONV void (*free_func)(void *));

#endif // SIMPLE_H_
