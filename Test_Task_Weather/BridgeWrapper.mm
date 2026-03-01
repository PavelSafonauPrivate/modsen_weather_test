#import "BridgeWrapper.h"

#include "bridge.h"

@implementation BridgeWrapper

+ (BOOL)isValidJSON:(NSString *)json {
    return is_valid_json(json.UTF8String) == 1;
}

+ (NSNumber *)doubleValueForPath:(NSString *)path inJSON:(NSString *)json {
    double value = 0.0;
    const int ok = get_double_by_path(json.UTF8String, path.UTF8String, &value);
    return (ok == 1) ? @(value) : nil;
}

+ (NSNumber *)intValueForPath:(NSString *)path inJSON:(NSString *)json {
    int value = 0;
    const int ok = get_int_by_path(json.UTF8String, path.UTF8String, &value);
    return (ok == 1) ? @(value) : nil;
}

+ (NSString *)stringValueForPath:(NSString *)path inJSON:(NSString *)json {
    char buffer[512] = {0};
    const int ok = get_string_by_path(json.UTF8String, path.UTF8String, buffer, sizeof(buffer));
    if (ok != 1) {
        return nil;
    }
    return [NSString stringWithUTF8String:buffer];
}

@end
