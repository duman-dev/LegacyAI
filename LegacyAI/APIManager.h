#import <Foundation/Foundation.h>

@interface APIManager : NSObject
+ (void)sendMessage:(NSString *)message apiKey:(NSString *)apiKey completion:(void(^)(NSString *response, NSError *error))completion;
@end
