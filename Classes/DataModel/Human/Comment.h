#import "_Comment.h"

@interface Comment : _Comment {}
+ (void)addComment:(NSString *)comment
           eventId:(NSString *)eventId
            userId:(NSString *)userId
            sucess:(void (^)(id response))handleSuccess
           failure:(void (^)(NSError *error))handleFailure;

+ (void)getCommentsWithEventId:(NSString *)eventId
                        sucess:(void (^)(NSArray *comment))handleSuccess
                       failure:(void (^)(NSError *error))handleFailure;
@end
