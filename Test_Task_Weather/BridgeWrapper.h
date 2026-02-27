#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BridgeWrapper : NSObject

+ (BOOL)isValidJSON:(NSString *)json;
+ (nullable NSNumber *)doubleValueForPath:(NSString *)path inJSON:(NSString *)json;
+ (nullable NSNumber *)intValueForPath:(NSString *)path inJSON:(NSString *)json;
+ (nullable NSString *)stringValueForPath:(NSString *)path inJSON:(NSString *)json;

@end

NS_ASSUME_NONNULL_END
