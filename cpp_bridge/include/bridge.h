#pragma once

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

int is_valid_json(const char* json_text);
int get_double_by_path(const char* json_text, const char* path, double* out_value);
int get_int_by_path(const char* json_text, const char* path, int* out_value);
int get_string_by_path(const char* json_text, const char* path, char* out_buffer, size_t out_buffer_size);

#ifdef __cplusplus
}
#endif
