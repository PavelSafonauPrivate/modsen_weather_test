#include "bridge.h"

#include <cstring>
#include <string>

#include <tao/json.hpp>

namespace {

const tao::json::value* find_path(const tao::json::value& root, const char* path)
{
    const tao::json::value* current = &root;
    std::string remaining(path);

    while (!remaining.empty()) {
        const std::size_t dot = remaining.find('.');
        const std::string segment = (dot == std::string::npos) ? remaining : remaining.substr(0U, dot);

        const std::size_t open = segment.find('[');
        const std::string key = (open == std::string::npos) ? segment : segment.substr(0U, open);
        current = &current->get_object().at(key);

        if (open != std::string::npos) {
            const std::size_t close = segment.find(']', open + 1U);
            const std::size_t index = static_cast<std::size_t>(std::stoul(segment.substr(open + 1U, close - open - 1U)));
            current = &current->get_array().at(index);
        }

        if (dot == std::string::npos) {
            break;
        }
        remaining = remaining.substr(dot + 1U);
    }

    return current;
}

}  // namespace

extern "C" int is_valid_json(const char* json_text)
{
    if (json_text == nullptr) {
        return 0;
    }

    try {
        (void)tao::json::from_string(json_text);
        return 1;
    } catch (...) {
        return 0;
    }
}

extern "C" int get_double_by_path(const char* json_text, const char* path, double* out_value)
{
    if (json_text == nullptr || path == nullptr || out_value == nullptr) {
        return 0;
    }

    try {
        const auto root = tao::json::from_string(json_text);
        const auto* value = find_path(root, path);
        if (value->is_double()) {
            *out_value = value->get_double();
            return 1;
        }
        if (value->is_signed()) {
            *out_value = static_cast<double>(value->get_signed());
            return 1;
        }
        if (value->is_unsigned()) {
            *out_value = static_cast<double>(value->get_unsigned());
            return 1;
        }
        return 0;
    } catch (...) {
        return 0;
    }
}

extern "C" int get_int_by_path(const char* json_text, const char* path, int* out_value)
{
    if (json_text == nullptr || path == nullptr || out_value == nullptr) {
        return 0;
    }

    try {
        const auto root = tao::json::from_string(json_text);
        const auto* value = find_path(root, path);
        if (value->is_signed()) {
            *out_value = static_cast<int>(value->get_signed());
            return 1;
        }
        if (value->is_unsigned()) {
            *out_value = static_cast<int>(value->get_unsigned());
            return 1;
        }
        return 0;
    } catch (...) {
        return 0;
    }
}

extern "C" int get_string_by_path(const char* json_text, const char* path, char* out_buffer, size_t out_buffer_size)
{
    if (json_text == nullptr || path == nullptr || out_buffer == nullptr || out_buffer_size == 0U) {
        return 0;
    }

    try {
        const auto root = tao::json::from_string(json_text);
        const std::string value = find_path(root, path)->get_string();
        if (value.size() + 1U > out_buffer_size) {
            return 0;
        }

        std::memcpy(out_buffer, value.c_str(), value.size() + 1U);
        return 1;
    } catch (...) {
        return 0;
    }
}
