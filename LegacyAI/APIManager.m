#import "APIManager.h"

@implementation APIManager

+ (void)sendMessage:(NSString *)message apiKey:(NSString *)apiKey completion:(void(^)(NSString *response, NSError *error))completion {
    // We use Groq's super fast API endpoint (OpenAI compatible)
    NSURL *url = [NSURL URLWithString:@"https://api.groq.com/openai/v1/chat/completions"];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    [req setValue:[NSString stringWithFormat:@"Bearer %@", apiKey] forHTTPHeaderField:@"Authorization"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *body = @{
        @"model": @"llama-3.3-70b-versatile",
        @"messages": @[ @{@"role": @"user", @"content": message} ]
    };
    
    NSError *jsonError;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&jsonError];
    if (jsonError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil, jsonError);
        });
        return;
    }
    req.HTTPBody = bodyData;
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completion(nil, error);
                return;
            }
            
            NSError *parseError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (parseError || !json[@"choices"]) {
                completion(nil, [NSError errorWithDomain:@"APIManagerError" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Groq sunucusundan geçersiz yanıt geldi."}]);
                return;
            }
            
            NSString *reply = json[@"choices"][0][@"message"][@"content"];
            completion(reply, nil);
        });
    }];
    [task resume];
}

@end
