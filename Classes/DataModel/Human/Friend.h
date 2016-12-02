#import "_Friend.h"

@interface Friend : _Friend {}

+ (void)obtainFriendsList:(void(^)(NSArray *friendIds))handleSuccess
                  failure:(void(^)(NSError *error))handleFailure;

+ (void)fetchMutualFriendsForUserId:(NSString *)userId
                      handleSuccess:(void (^)(NSArray *mutualFriends))handleSuccess
                            failure:(void(^)(NSError *error))handleFailure;

+ (NSArray *)sortFriends:(NSArray *)friends;

@end
