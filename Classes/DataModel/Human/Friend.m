#import "Friend.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "MMHTTPClient.h"

@interface Friend ()
@end


@implementation Friend

+ (void)obtainFriendsList:(void(^)(NSArray *friendIds))handleSuccess
                  failure:(void(^)(NSError *error))handleFailure{
    
    User *currentUser = [User currentUser];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSDictionary *friendsListParameters = nil;
    friendsListParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                             currentUser.userId, @"userid",
                             currentUser.accessToken,@"access_token",
                             nil];
    
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_friends_list]
                       parameters:friendsListParameters];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         //NSError *jsonError = nil;
         TALog(@"JSON:%@",JSON);
         TALog(@"Response:%@",response);
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSMutableArray *responseArray = [[NSMutableArray alloc] init];
             
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             NSDictionary *resultDict = [jsonDictionary objectForKey:@"result"];
             NSArray *friendsArray = [resultDict objectForKey:@"data"];
             for (id friend in friendsArray) {
                 if ([friend isKindOfClass:[NSDictionary class]]) {
                     
                     NSDictionary *friendDict = (NSDictionary *)friend;
                     Friend *friend = [self parseFriendInfo:friendDict];
                     [responseArray addObject:friend];
                 }
             }
             handleSuccess(responseArray);
         }
         
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
         
     }];
    [operation start];
}

+ (void)fetchMutualFriendsForUserId:(NSString *)userId
                      handleSuccess:(void (^)(NSArray *mutualFriends))handleSuccess
                            failure:(void(^)(NSError *error))handleFailure{
    
    
    User *currentUser = [User currentUser];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSDictionary *friendsListParameters = nil;
    friendsListParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                             currentUser.userId, @"userid",
                             currentUser.accessToken,@"access_token",
                             userId,@"stranger_id",
                             nil];
    
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_mutualFriends]
                       parameters:friendsListParameters];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

         TALog(@"JSON:%@",JSON);
         TALog(@"Response:%@",response);
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             NSDictionary *resultDict = [jsonDictionary objectForKey:@"result"];
             NSArray *friendsArray = [resultDict objectForKey:@"data"];
             NSMutableArray *result = [[NSMutableArray alloc] init];

             for(NSDictionary *friendDict in friendsArray){
                 Friend *friend = [self parseFriendInfo:friendDict];
                 [result addObject:friend];
             }
             handleSuccess(result);
         }
         
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
         
     }];
    [operation start];
}

+ (Friend *)parseFriendInfo:(NSDictionary *)friendDict{
    
    TALog(@"Friend Dict : %@",friendDict);
    
    NSString *friendUserId = [friendDict valueForKey:@"user_id"];
    NSString *friendName = [friendDict valueForKey:@"name"];
    
    Friend *resultFriend = [Friend doesFriendExistsWithFriendId:friendUserId];

    User *currentUser = [User currentUser];
    if (resultFriend == nil) {
        Friend *newFriend = [Friend MR_createInContext:[NSManagedObjectContext defaultContext]];
        newFriend.friendId = friendUserId;
        newFriend.friendName = friendName;
        resultFriend = newFriend;
        
        [currentUser addFriendsObject:newFriend];
        [[NSManagedObjectContext MR_defaultContext] saveToPersistentStoreWithCompletion:nil];
    }else{
        resultFriend.friendName = friendName;
    }
    return resultFriend;
}

+ (Friend *)doesFriendExistsWithFriendId:(NSString *)friendId {
    NSArray *friends = [[[User currentUser] friends] allObjects];
    for (Friend *friend in friends) {
        TALog(@"friend id : %@",friend.friendName);
        if ([friend.friendId isEqualToString:friendId]) {
            return friend;
        }
    }
    return nil;
}

+ (NSArray *)sortFriends:(NSArray *)friends{
    
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor
                                        sortDescriptorWithKey:@"friendName"
                                        ascending:YES];
    
    return [friends sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
}


@end
