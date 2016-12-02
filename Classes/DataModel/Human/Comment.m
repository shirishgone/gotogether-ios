#import "Comment.h"
#import "AFHTTPRequestOperation.h"
#import "goTogetherAppDelegate.h"
#import "AFJSONRequestOperation.h"
#import "TAFacebookManager.h"
#import "TALocationManager.h"
#import "AFHTTPClient.h"
#import "MMHTTPClient.h"
#import "NSDate+GTExtensions.h"

@interface Comment ()
@end

@implementation Comment

+ (void)getCommentsWithEventId:(NSString *)eventId
                        sucess:(void (^)(NSArray *comment))handleSuccess
                       failure:(void (^)(NSError *error))handleFailure{
    
    User *currentUser = [User currentUser];

    Event *event = [Event eventForEventId:eventId];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSDictionary *commentParameters = nil;
    commentParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                         event.eventId, @"event_id",
                         currentUser.userId,@"userid",
                         currentUser.accessToken, @"access_token",
                         nil];

    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_getComments]
                       parameters:commentParameters];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSMutableArray *responseArray = [[NSMutableArray alloc] init];
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             
             id error = [jsonDictionary valueForKey:@"error"];
             if ([MMHTTPClient isError:error]) {
                 handleFailure(error);
                 return ;
             }else{
                 NSDictionary *resultDict = [jsonDictionary valueForKey:@"result"];
                 NSDictionary *dataDict = [resultDict valueForKey:@"data"];
                 NSArray *commentsArray = [dataDict objectForKey:@"comments"];
                 
                 for (id comment in commentsArray) {
                     if ([comment isKindOfClass:[NSDictionary class]]) {
                         
                         NSDictionary *commentDict = (NSDictionary *)comment;
                         Comment *comment = [self commentFromDictionary:commentDict forEventId:eventId];
                         Event *event = [Event eventForEventId:eventId];
                         if ([event.comments containsObject:comment] == NO) {
                             [event addCommentsObject:comment];
                         }

                         [responseArray addObject:comment];
                     }
                 }
                 handleSuccess(responseArray);

             }
         }
         
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
         
     }];
    [operation start];

}

+ (void)addComment:(NSString *)commentString
           eventId:(NSString *)eventId
            userId:(NSString *)commentedUserId
            sucess:(void (^)(id response))handleSuccess
           failure:(void (^)(NSError *error))handleFailure{
    
    User *currentUser = [User currentUser];

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:commentedUserId forKey:@"userid"];
    [parameters setObject:eventId forKey:@"event_id"];
    [parameters setObject:currentUser.accessToken forKey:@"access_token"];
    [parameters setObject:commentString forKey:@"comment"];
    NSDate *commentedDate = [NSDate date];
    NSString *commentedDateString = [NSDate dateStringForDate:commentedDate];
    
    [parameters setObject:commentedDateString forKey:@"date_time"];
    
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_addComment]
                       parameters:parameters];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSDictionary *responseDictionary =[NSJSONSerialization
                                           JSONObjectWithData:responseObject
                                           options:NSJSONReadingMutableContainers
                                           error:nil];
        
        
        Comment *comment = [Comment MR_createInContext:[NSManagedObjectContext defaultContext]];
        comment.commentedUserId = commentedUserId;
        comment.commentString = commentString;
        [comment setCommentedDate:commentedDate];
        [[NSManagedObjectContext MR_defaultContext] saveToPersistentStoreWithCompletion:nil];
        
        Event *event = [Event eventForEventId:eventId];
        [event addCommentsObject:comment];
        
        NSString *commentedUserId = [responseDictionary objectForKey:@"commentedUserId"];
        handleSuccess(commentedUserId);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        TALog(@"error: %@",error);
        handleFailure(error);
        
    }];
    [requestOperation start];

}

#pragma mark - core data methods
+ (Comment *)commentFromDictionary:(NSDictionary *)commentDict forEventId:(NSString *)eventId{
    
    TALog(@"comment dict : %@",commentDict);
    
    NSString *commentedUserId = [NSString stringWithFormat:@"%@",[commentDict valueForKey:@"userid"]];
    NSString *commentString = [commentDict valueForKey:@"comment"];
    NSString *commentedDate = [commentDict valueForKey:@"data_time"];
    NSString *commentedUserName = [commentDict valueForKey:@"name"];
    
    Comment *commentInfo =
    [Comment isCommentExistsForEventId:eventId
                       commentedUserId:commentedUserId
                               comment:commentString
                         commentedDate:commentedDate
     ];
    
    if (commentInfo == nil) {
        commentInfo = [Comment MR_createInContext:[NSManagedObjectContext defaultContext]];
        commentInfo.commentedUserId = commentedUserId;
        commentInfo.commentString = commentString;
        [commentInfo setCommentedDate:[[NSDate dateFormatter] dateFromString:commentedDate]];
        [commentInfo setCommentedUserName:commentedUserName];
        [[NSManagedObjectContext MR_defaultContext] saveToPersistentStoreWithCompletion:nil];
    }
    
    return commentInfo;
}

+ (Comment *)isCommentExistsForEventId:(NSString *)eventId
                       commentedUserId:(NSString *)commentedUserId
                               comment:(NSString *)commentString
                         commentedDate:(NSString *)commentedDateString{
    
    NSDateFormatter *dateFormatter = [NSDate dateFormatter];
    NSDate *commentedDate = [dateFormatter dateFromString:commentedDateString];
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"commentString == %@ AND commentedDate == %@ AND commentedUserId == %@", commentString, commentedDate, commentedUserId];
    Comment *comment = [Comment MR_findFirstWithPredicate:predicate inContext:defaultContext];
    return comment;
}

@end
