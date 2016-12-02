

#import "Event.h"
#import "AFHTTPRequestOperation.h"
#import "goTogetherAppDelegate.h"
#import "AFJSONRequestOperation.h"
#import "TAFacebookManager.h"
#import "TALocationManager.h"
#import "Comment.h"
#import "Place.h"
#import "AFHTTPClient.h"
#import "TARoute.h"
#import "NSManagedObject+MagicalRecord.h"
#import "CoreData+MagicalRecord.h"
#import "User.h"
#import "MMHTTPClient.h"
#import "GTTravellerDetails.h"

#define SORT_KEY @"distance"

@interface Event ()
@end

@implementation Event

+ (void)aroundMeForLatitude:(double)latitude
                  longitude:(double)longitude
                       date:(NSDate *)date
                     radius:(int)radius
                     sucess:(void(^)(NSArray *rides))handleSuccess
                    failure:(void (^)(NSError *error))handleFailure{

    User *currentUser = [User currentUser];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:currentUser.userId forKey:@"userid"];
    [parameters setObject:currentUser.accessToken forKey:@"access_token"];
    
    [parameters setObject:[NSNumber numberWithDouble:latitude] forKey:@"from_latitude"];
    [parameters setObject:[NSNumber numberWithDouble:longitude] forKey:@"from_longitude"];
    [parameters setObject:[NSDate dateStringForDate:date] forKey:@"date"];
    [parameters setObject:[NSNumber numberWithInt:radius] forKey:@"radius"];
    
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_aroundMe]
                       parameters:parameters];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        id JSON =[NSJSONSerialization
                  JSONObjectWithData:responseObject
                  options:NSJSONReadingMutableContainers
                  error:nil];
        id error = [JSON valueForKey:@"error"];
        id result = [JSON valueForKey:@"result"];
        if ([MMHTTPClient isError:error]) {
            handleFailure(error);
            return;
        }else{
            NSMutableArray *resultArray = [NSMutableArray array];
            if ([result isKindOfClass:[NSDictionary class]]) {
                id data = [result valueForKey:@"data"];
                if ([data isKindOfClass:[NSArray class]]) {
                    for (id event in data) {
                        Event *parsedEvent = [self parseEventInfo:event];
                        [resultArray addObject:parsedEvent];
                    }
                }
            }
            handleSuccess(resultArray);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handleFailure(error);
        return ;
    }];
    [requestOperation start];
}


+ (void)searchEventForSearchType:(GTUserType)userType
                      withSource:(Place *)source
                     destination:(Place *)destination
                            date:(NSDate *)date
                          sucess:(void(^)(NSArray *rides))handleSuccess
                         failure:(void (^)(NSError *error))handleFailure{

    User *currentUser = [User currentUser];

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:currentUser.userId forKey:@"userid"];
    [parameters setObject:currentUser.accessToken forKey:@"access_token"];
    [parameters setObject:@"owner" forKey:@"user_type"];
    [parameters setObject:destination.latitude forKey:@"to_latitude"];
    [parameters setObject:destination.longitude forKey:@"to_longitude"];
    [parameters setObject:source.latitude forKey:@"from_latitude"];
    [parameters setObject:source.longitude forKey:@"from_longitude"];
    [parameters setObject:[NSDate dateStringForDate:date] forKey:@"date"];
    [parameters setObject:source.displayName forKey:@"source_name"];
    [parameters setObject:destination.displayName forKey:@"destination_name"];
    
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_eventSearch]
                       parameters:parameters];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        id JSON =[NSJSONSerialization
                  JSONObjectWithData:responseObject
                  options:NSJSONReadingMutableContainers
                  error:nil];
        id error = [JSON valueForKey:@"error"];
        id result = [JSON valueForKey:@"result"];
        if ([MMHTTPClient isError:error]) {
            handleFailure(error);
            return;
        }else{
            NSMutableArray *resultArray = [NSMutableArray array];
            if ([result isKindOfClass:[NSDictionary class]]) {
                id data = [result valueForKey:@"data"];
                if ([data isKindOfClass:[NSArray class]]) {
                    for (id event in data) {
                        Event *parsedEvent = [self parseEventInfo:event];
                        [resultArray addObject:parsedEvent];
                    }
                }
            }
            handleSuccess(resultArray);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handleFailure(error);
        return ;
    }];
    [requestOperation start];
}

+ (void)createEventWithDetails:(Event *)event
                        sucess:(void (^)(Event *event))handleSuccess
                       failure:(void (^)(NSError *error))handleFailure{
        
    User *currentUser = [User currentUser];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:currentUser.userId forKey:@"userid"];
    [parameters setObject:currentUser.accessToken forKey:@"access_token"];
    [parameters setObject:event.eventType forKey:@"event_type"];
    [parameters setObject:event.userType forKey:@"user_type"];
    [parameters setObject:event.destinationLatitude forKey:@"tolatitude"];
    [parameters setObject:event.destinationLongitude forKey:@"tolongitude"];
    [parameters setObject:event.sourceLatitude forKey:@"fromlatitude"];
    [parameters setObject:event.sourceLongitude forKey:@"fromlongitude"];
    [parameters setObject:[NSDate dateStringForDate:event.dateTime] forKey:@"date"];
    [parameters setObject:event.destinationName forKey:@"to_location_name"];
    [parameters setObject:event.sourceName forKey:@"from_location_name"];
    [parameters setObject:[NSDate dateStringForDate:[NSDate date]] forKey:@"created_date"];

    NSMutableString *coTravellersString = [[NSMutableString alloc] init];
    [coTravellersString appendString:currentUser.userId];
    for (int i=0 ; i< [event.travellers_list count]; i++) {
        [coTravellersString appendString:[event.travellers_list objectAtIndex:i]];
        if (i+1 != [event.travellers_list count]) {
            [coTravellersString appendString:@","];
        }
    }
    [parameters setObject:coTravellersString forKey:@"travellers_list"];
    
    if (event.routePoints !=nil) {
        [parameters setObject:event.routePoints forKey:@"route"];
    }
    if (event.seatPrice !=nil) {
        [parameters setObject:event.seatPrice forKey:@"price"];
    }
    if (event.availableSeats !=nil) {
        [parameters setObject:event.availableSeats forKey:@"seats"];
    }

    
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_createEvent]
                       parameters:parameters];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSDictionary *responseDictionary =[NSJSONSerialization
                                           JSONObjectWithData:responseObject
                                           options:NSJSONReadingMutableContainers
                                           error:nil];
        
        NSDictionary *resultDict = [responseDictionary objectForKey:@"result"];
        id error = [responseDictionary objectForKey:@"error"];
        if ([MMHTTPClient isError:error]) {
            handleFailure(error);
            return ;
        }
        NSString *eventId = [[resultDict valueForKey:@"eventid"] stringValue];
        event.eventId = eventId;
        event.travellers_list = @[currentUser.userId];
        [[NSManagedObjectContext MR_defaultContext] saveToPersistentStoreWithCompletion:nil];
        handleSuccess(event);
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handleFailure(error);
        
    }];
    [requestOperation start];
}

+ (void)editEventWithDetails:(Event *)event
                      sucess:(void (^)(Event *event))handleSuccess
                     failure:(void (^)(NSError *error))handleFailure {
    
    User *currentUser = [User currentUser];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:currentUser.userId forKey:@"userid"];
    [parameters setObject:currentUser.accessToken forKey:@"access_token"];
    [parameters setObject:event.eventId forKey:@"event_id"];
    [parameters setObject:event.eventType forKey:@"event_type"];
    [parameters setObject:event.userType forKey:@"user_type"];
    [parameters setObject:event.destinationLatitude forKey:@"tolatitude"];
    [parameters setObject:event.destinationLongitude forKey:@"tolongitude"];
    [parameters setObject:event.sourceLatitude forKey:@"fromlatitude"];
    [parameters setObject:event.sourceLongitude forKey:@"fromlongitude"];
    [parameters setObject:[NSDate dateStringForDate:event.dateTime] forKey:@"date"];
    [parameters setObject:event.destinationName forKey:@"to_location_name"];
    [parameters setObject:event.sourceName forKey:@"from_location_name"];

    if (event.routePoints !=nil) {
        [parameters setObject:event.routePoints forKey:@"route"];
    }
    if (event.seatPrice !=nil) {
        [parameters setObject:event.seatPrice forKey:@"price"];
    }
    if (event.availableSeats !=nil) {
        [parameters setObject:event.availableSeats forKey:@"seats"];
    }

    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotAPi_editEvent]
                       parameters:parameters];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSDictionary *responseDictionary = [NSJSONSerialization
                                            JSONObjectWithData:responseObject
                                            options:NSJSONReadingMutableContainers
                                            error:nil];
        
        NSDictionary *resultDict = [responseDictionary objectForKey:@"result"];
        id error = [responseDictionary objectForKey:@"error"];
        if ([MMHTTPClient isError:error]) {
            handleFailure(error);
            return ;
        }
        NSString *eventId = [[resultDict valueForKey:@"eventid"] stringValue];
        event.eventId = eventId;
        NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
        [defaultContext saveToPersistentStoreWithCompletion:nil];
        handleSuccess(event);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handleFailure(error);
        
    }];
    [requestOperation start];
}

+ (void)cancelEventWithDetails:(Event *)event
                        sucess:(void (^)(NSString* successMessage))handleSuccess
                       failure:(void (^)(NSError *error))handleFailure{

    User *currentUser = [User currentUser];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:currentUser.userId forKey:@"userid"];
    [parameters setObject:currentUser.accessToken forKey:@"access_token"];
    [parameters setObject:event.eventId forKey:@"event_id"];
    
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotAPi_cancelEvent]
                       parameters:parameters];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *responseDictionary = [NSJSONSerialization
                                            JSONObjectWithData:responseObject
                                            options:NSJSONReadingMutableContainers
                                            error:nil];
        
        id error = [responseDictionary objectForKey:@"error"];
        if ([MMHTTPClient isError:error]) {
            handleFailure(error);
            return ;
        }

        [[NSNotificationCenter defaultCenter]
         postNotificationName:kNotificationType_eventDeleted
                object:nil];
        
        handleSuccess(@"deleted successfully");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handleFailure(error);
        
    }];
    [requestOperation start];
}


+ (void)bookASeatinEventWithId:(NSString *)eventId
                     seatCount:(int)seatCount
                        sucess:(void (^)(id response))handleSuccess
                       failure:(void (^)(NSError *error))handleFailure{
    
    User *currentUser = [User currentUser];

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    NSInteger totalSeats = 1;
    NSNumber *myInt = [NSNumber numberWithInteger:totalSeats];

    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    NSDictionary *bookSeatParameters = nil;
    bookSeatParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                          eventId, @"event_id",
                          currentUser.userId,@"userid",
                          currentUser.accessToken,@"access_token",
                          myInt,@"seats_count",
                          
                          nil];
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_bookSeat]
                       parameters:bookSeatParameters];
        
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         TALog(@"response: %@",response);
         TALog(@"JSON: %@",JSON);
         handleSuccess(response);
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];
}

+ (void)confirmSeatWithEventId:(NSString *)eventId
                 requestUserId:(NSString *)requestUserId
                     seatCount:(int)seatCount
                      userType:(GTUserType)userType
                        sucess:(void (^)(id response))handleSuccess
                       failure:(void (^)(NSError *error))handleFailure{
    
    User *currentUser = [User currentUser];

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:currentUser.userId forKey:@"userid"];
    [parameters setObject:currentUser.accessToken forKey:@"access_token"];
    [parameters setObject:eventId forKey:@"event_id"];
    [parameters setObject:requestUserId forKey:@"friend_id"];
    [parameters setObject:[NSNumber numberWithInt:seatCount] forKey:@"seats_count"];
    
    if (userType == userType_driving) {
        [parameters setObject:@"owner" forKey:@"user_type"];
    }else{
        [parameters setObject:@"passenger" forKey:@"user_type"];
    }
    
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_confirmSeat]
                       parameters:parameters];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

         TALog(@"JSON: %@",JSON);
         handleSuccess(response);
         
         
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         
         handleFailure(error);
     }];
    [operation start];
}

+ (void)getEventDetailsWithEventId:(NSString *)eventId
                            sucess:(void (^)(Event *event))handleSuccess
                           failure:(void (^)(NSError *error))handleFailure{
        
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    User *currentUser = [User currentUser];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:currentUser.userId forKey:@"userid"];
    [parameters setObject:currentUser.accessToken forKey:@"access_token"];
    [parameters setObject:eventId forKey:@"event_id"];
    NSMutableURLRequest *request =

    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_eventDetails]
                       parameters:parameters];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

         NSDictionary *jsonDictionary = (NSDictionary *)JSON;
         id error = [jsonDictionary valueForKey:@"error"];
         if ([MMHTTPClient isError:error]) {
             handleFailure(error);
             return;
         }
         
         id result = [jsonDictionary valueForKey:@"result"];
         if ([result isKindOfClass:[NSArray class]]) {
             id event = [result lastObject];
             Event *eventInfo = [self parseEventInfo:event];
             handleSuccess(eventInfo);
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];

}

+ (void)fetchRouteForEventId:(NSString *)eventId
                      sucess:(void (^)(NSString *routePoints))handleSuccess
                     failure:(void (^)(NSError *error))handleFailure{
    
    User *currentUser = [User currentUser];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    NSDictionary *parameters = nil;
    
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                             eventId, @"event_id",
                             currentUser.userId,@"userid",
                             currentUser.accessToken,@"access_token",
                             nil];

    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_routepoints]
                       parameters:parameters];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSError *jsonError = [NSError errorWithDomain:@"No Route Information found"
                                                  code:NSIntegerMax
                                              userInfo:nil];
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             id error = [jsonDictionary valueForKey:@"error"];
             if ([MMHTTPClient isError:error]) {
                 handleFailure(error);
                 return;
             }
             NSDictionary  *resultDict = [jsonDictionary valueForKey:@"result"];
             if (resultDict !=nil) {
                 NSDictionary *dataDict = [resultDict valueForKey:@"data"];
                 if (dataDict !=nil) {
                     NSString *routePoints = [dataDict valueForKey:@"route_points"];
                     if (routePoints !=nil && [routePoints length] > 1) {
                         handleSuccess(routePoints);
                         return;
                     }
                 }
             }
             handleFailure(jsonError);
         }
         
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];
}

+ (void)obtainRidesForUserId:(NSString *)userId
                     success:(void(^)(NSArray *response))handleSuccess
                     failure:(void(^)(NSError *error))handleFailure {
    
    
    User *currentUser = [User currentUser];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableDictionary *parametersDictionary = [NSMutableDictionary dictionary];
    [parametersDictionary setObject:currentUser.userId forKey:@"userid"];
    [parametersDictionary setObject:currentUser.accessToken forKey:@"access_token"];
    
    if ([userId isEqualToString:currentUser.userId] == NO && userId != nil) {
        [parametersDictionary setObject:userId forKey:@"friend_id"];
    }
    
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_myEvents]
                       parameters:parametersDictionary];
    
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
                 return;
             }else{
                 NSDictionary *resultDict = [jsonDictionary objectForKey:@"result"];
                 if ([[resultDict allKeys] containsObject:@"data"]) {
                     NSArray *eventsArray = [resultDict valueForKey:@"data"];
                     for (id event in eventsArray) {
                         if ([event isKindOfClass:[NSDictionary class]]) {
                             
                             NSDictionary *eventDict = (NSDictionary *)event;
                             Event *event = [self parseEventInfo:eventDict];
                             [responseArray addObject:event];                             
                         }
                     }
                     NSArray *sortedArray = [self sortEventsByEventDate:responseArray];
                     handleSuccess(sortedArray);
                 }
             }
         }
         
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
         
     }];
    [operation start];
}


+ (void)fetchFriendFeed:(void(^)(NSArray *rides))handleSuccess
                failure:(void(^)(NSError *error))handleFailure{
    
    User *currentUser = [User currentUser];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSDictionary *liveFeedParameters = nil;
    liveFeedParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                          currentUser.userId, @"userid",
                          currentUser.accessToken,@"access_token",
                          nil];
    
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_friendFeed]
                       parameters:liveFeedParameters];

    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSMutableArray *responseArray = [[NSMutableArray alloc] init];
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             
             id error = [jsonDictionary valueForKey:@"error"];
             id result = [jsonDictionary objectForKey:@"result"];
             
             if ([MMHTTPClient isError:error]) {
                 handleFailure(error);
                 return;
             }
             
             if ([result isKindOfClass:[NSDictionary class]]) {
                 if ([[result allKeys] count] > 0) {
                     
                     NSArray *eventsArray = [result valueForKey:@"data"];
                     for (id event in eventsArray) {
                         if ([event isKindOfClass:[NSDictionary class]]) {
                             
                             NSDictionary *eventDict = (NSDictionary *)event;
                             Event *event = [self parseEventInfo:eventDict];
                             [responseArray addObject:event];
                         }
                     }
                     
                     NSArray *sortedArray = [self sortEventsByEventDate:responseArray];
                     handleSuccess(sortedArray);
                     return;
                 }
             }
         }

     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);

     }];
    [operation start];
}


+ (void)browseRidesForPage:(NSInteger)pageCount
               WithSuccess:(void(^)(NSArray *rides, NSInteger totalPages))handleSuccess
                   failure:(void(^)(NSError *error))handleFailure{
    
    User *currentUser = [User currentUser];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:currentUser.userId forKey:@"userid"];
    [parameters setObject:currentUser.accessToken forKey:@"access_token"];
    [parameters setObject:[NSNumber numberWithInteger:pageCount] forKey:@"page"];
    [parameters setObject:[NSDate dateStringForDate:[NSDate date]] forKey:@"date"];

    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_browseRides]
                       parameters:parameters];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSMutableArray *responseArray = [[NSMutableArray alloc] init];
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             
             id error = [jsonDictionary valueForKey:@"error"];
             id result = [jsonDictionary objectForKey:@"result"];
             
             if ([MMHTTPClient isError:error]) {
                 handleFailure(error);
                 return;
             }
             
             if ([result isKindOfClass:[NSDictionary class]]) {
                 NSInteger totalPagesCount = [[result valueForKey:@"total_pages"] integerValue];
                 if ([[result allKeys] count] > 0) {
                     
                     NSArray *eventsArray = [result valueForKey:@"data"];
                     for (id event in eventsArray) {
                         if ([event isKindOfClass:[NSDictionary class]]) {
                             NSDictionary *eventDict = (NSDictionary *)event;
                             Event *event = [self parseEventInfo:eventDict];
                             [responseArray addObject:event];
                         }
                     }
                 }
                 handleSuccess(responseArray,totalPagesCount);
                 return;
             }
         }
         
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
         
     }];
    [operation start];
}

#pragma mark - Parsing
+ (Event *)parseEventInfo:(NSDictionary *)eventDict{
    
    TALog(@"event Dict : %@",eventDict);
    NSString *eventId = [NSString stringWithFormat:@"%@",[eventDict valueForKey:@"id"]];
    
    Event *event = nil;
    Event *existingEvent = [Event eventForEventId:eventId];
    if (existingEvent == nil){
        event = [Event saveNewEventFromDictionary:eventDict];
    }else{
        event = [Event updateEvent:existingEvent withDictionary:eventDict];
    }
    return event;
}

#pragma mark - core data methods

+ (Event *)saveNewEventFromDictionary:(NSDictionary *)eventDict {

    Event *eventInfo = [Event MR_createInContext:[NSManagedObjectContext defaultContext]];
    eventInfo.eventId = [NSString stringWithFormat:@"%@",[eventDict valueForKey:@"id"]];
    eventInfo.userId = [eventDict valueForKey:@"userid"];
    eventInfo.userName = [eventDict valueForKey:@"name"];
    eventInfo.userType = [eventDict valueForKey:@"user_type"];
    eventInfo.eventType = [eventDict valueForKey:@"event_type"];
    eventInfo.availableSeats = [NSNumber numberWithInt:[[eventDict valueForKey:@"seats"] intValue]];
    
    [eventInfo setSourceLatitudeValue:[[eventDict valueForKey:@"fromLatitude"] doubleValue]];
    [eventInfo setSourceLongitudeValue:[[eventDict valueForKey:@"fromLongitude"] doubleValue]];
    [eventInfo setSourceName:[eventDict valueForKey:@"from_location_name"]];
    [eventInfo setDestinationLatitudeValue:[[eventDict valueForKey:@"toLatitude"] doubleValue]];
    [eventInfo setDestinationLongitudeValue:[[eventDict valueForKey:@"toLongitude"] doubleValue]];
    [eventInfo setDestinationName:[eventDict valueForKey:@"to_location_name"]];
    
    NSDateFormatter *dateFormatter = [NSDate dateFormatter];
    [eventInfo setDateTime:[dateFormatter dateFromString:[eventDict valueForKey:@"date_time"]]];
    [eventInfo setCreatedDate:[dateFormatter dateFromString:[eventDict valueForKey:@"created_date"]]];
    [eventInfo setSeatPriceValue:[[eventDict valueForKey:@"seat_price"] floatValue]];

    [eventInfo setTravellers_list:[eventDict valueForKey:@"travellers_list"]];
    [eventInfo setRequestedUsers:[eventDict valueForKey:@"requested_users"]];
    
    // Travellers Details
    NSArray *travellersDetails = [eventDict valueForKey:@"travellers_details"];
    [eventInfo setTravellersListDetails:[self travellersDetailsForDict:travellersDetails]];
    // Requested users
    NSArray *requestedUsersDetails = [eventDict valueForKey:@"requested_user_details"];
    [eventInfo setRequestedUserDetails:[self travellersDetailsForDict:requestedUsersDetails]];
    
    //Vehicle details
    Vehicle *vehicle = [self vehicleDetailsFromDict:[eventDict valueForKey:@"vehicle_details"]];
    eventInfo.vehicle = vehicle;
    
    [[NSManagedObjectContext MR_defaultContext] saveToPersistentStoreWithCompletion:nil];
    
    return eventInfo;
}

+ (Event *)updateEvent:(Event *)eventInfo withDictionary:(NSDictionary *)eventDict{
    
    eventInfo.userType = [eventDict valueForKey:@"user_type"];
    eventInfo.eventType = [eventDict valueForKey:@"event_type"];
    eventInfo.availableSeats = [NSNumber numberWithInt:[[eventDict valueForKey:@"seats"] intValue]];
    
    [eventInfo setSourceLatitudeValue:[[eventDict valueForKey:@"fromLatitude"] doubleValue]];
    [eventInfo setSourceLongitudeValue:[[eventDict valueForKey:@"fromLongitude"] doubleValue]];
    [eventInfo setSourceName:[eventDict valueForKey:@"from_location_name"]];
    [eventInfo setDestinationLatitudeValue:[[eventDict valueForKey:@"toLatitude"] doubleValue]];
    [eventInfo setDestinationLongitudeValue:[[eventDict valueForKey:@"toLongitude"] doubleValue]];
    [eventInfo setDestinationName:[eventDict valueForKey:@"to_location_name"]];
    
    NSDateFormatter *dateFormatter = [NSDate dateFormatter];
    [eventInfo setDateTime:[dateFormatter dateFromString:[eventDict valueForKey:@"date_time"]]];
    [eventInfo setCreatedDate:[dateFormatter dateFromString:[eventDict valueForKey:@"created_date"]]];
    [eventInfo setSeatPriceValue:[[eventDict valueForKey:@"seat_price"] floatValue]];
    
    [eventInfo setTravellers_list:[eventDict valueForKey:@"travellers_list"]];
    [eventInfo setRequestedUsers:[eventDict valueForKey:@"requested_users"]];
    
    // Travellers Details
    NSArray *travellersDetails = [eventDict valueForKey:@"travellers_details"];
    [eventInfo setTravellersListDetails:[self travellersDetailsForDict:travellersDetails]];
    
    // Requested users
    NSArray *requestedUsersDetails = [eventDict valueForKey:@"requested_user_details"];
    [eventInfo setRequestedUserDetails:[self travellersDetailsForDict:requestedUsersDetails]];
    
    //Vehicle details
    Vehicle *vehicle = [self vehicleDetailsFromDict:[eventDict valueForKey:@"vehicle_details"]];
    eventInfo.vehicle = vehicle;
    
    [[NSManagedObjectContext MR_defaultContext] saveToPersistentStoreWithCompletion:nil];
    
    return eventInfo;
}

+ (Vehicle *)vehicleDetailsFromDict:(NSDictionary *)vehicleDict {
    
    Vehicle *vehicle = [Vehicle MR_createEntity];
    vehicle.vehicleNumber = [vehicleDict valueForKey:@"vehicle_number"];
    vehicle.make = [vehicleDict valueForKey:@"make"];
    vehicle.model = [vehicleDict valueForKey:@"model"];
    return vehicle;
}

+ (NSArray *)travellersDetailsForDict:(NSArray *)travellersDictArray {
    NSMutableArray *travellersDetailsArray = [[NSMutableArray alloc] init];
    for (id travellerDict in travellersDictArray) {
        GTTravellerDetails *traveller_details = [[GTTravellerDetails alloc] init];
        [traveller_details setUserId:[travellerDict valueForKey:@"userid"]];
        NSString *mobile = [travellerDict valueForKey:@"mobile"];
        if (mobile!=nil) {
            [traveller_details setPhoneNumber:mobile];
        }
        [traveller_details setName:[travellerDict valueForKey:@"name"]];
        [travellersDetailsArray addObject:traveller_details];
    }
    return travellersDetailsArray;
}

+ (BOOL)isEventByCurrentUser:(NSString *)eventId{
    BOOL isCurrentUserEvent = NO;
    Event *event = [Event eventForEventId:eventId];
    User *currentUser = [User currentUser];
    if (event !=nil && [event.userId isEqualToString:currentUser.userId]) {
        isCurrentUserEvent = YES;
    }
    return isCurrentUserEvent;
}

+ (Event *)eventForEventId:(NSString *)eventid{

    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventId == %@", eventid];
    Event *event = [Event MR_findFirstWithPredicate:predicate inContext:defaultContext];
    if (event) {
        return event;
    }
    else{
        return nil;
    }
}

+ (NSArray *)eventsOfUserWithUserId:(NSString *)userId{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", userId];
    NSArray *events = [Event MR_findAllWithPredicate:predicate
                                           inContext:[NSManagedObjectContext defaultContext]];
    return events;
}

#pragma mark - convenience methods

//+ (NSArray *)passengersArrayFromString:(NSString *)travellersListString{
//    travellersListString = [travellersListString stringByReplacingOccurrencesOfString:@"[" withString:@""];
//    travellersListString = [travellersListString stringByReplacingOccurrencesOfString:@"]" withString:@""];
//    travellersListString = [travellersListString stringByReplacingOccurrencesOfString:@"'" withString:@""];
//    travellersListString = [travellersListString stringByReplacingOccurrencesOfString:@" " withString:@""];
//    travellersListString = [travellersListString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//    travellersListString = [travellersListString stringByReplacingOccurrencesOfString:@" " withString:@""];
//    
//    NSArray *subStrings = nil;
//    if (travellersListString.length != 0) {
//        subStrings = [travellersListString componentsSeparatedByString:@","];
//    }
//    NSMutableArray *passengers = [NSMutableArray array];
//
//    for (NSString *substring in subStrings) {
//        if (substring.length > 0) {
//            [passengers addObject:substring];
//        }
//    }
//    
//    return passengers;
//}

+ (GTUserType)userTypeForString:(NSString *)userTypeString{
    
    if ([[userTypeString lowercaseString] isEqualToString:@"owner"]) {
        return userType_driving;
    }else{
        return userType_passenger;
    }
}

+ (NSString *)userTypeStringForType:(GTUserType )userType{
    
    if (userType == userType_driving) {
        return @"owner";
    }else{
        return @"passenger";
    }
}

- (BOOL)canShowNotifications {
    
    if([Event isEventByCurrentUser:self.eventId] == YES &&
       [self isOlderEvent] == NO &&
       [[self rideRequests] count] > 0){
        
        return YES;
    }
    return NO;
}

- (NSArray *)rideRequests {
    NSMutableArray *requests = [NSMutableArray array];
    NSArray *requestedUsers = self.requestedUsers;
    for (NSString *requestedUserId in requestedUsers) {
        if ([self isUserInTravellersList:requestedUserId] == NO) {
            [requests addObject:requestedUserId];
        }
    }
    return requests;
}

- (GTUserType)userTypeValue {
    if ([[self.userType lowercaseString] isEqualToString:@"owner"]) {
        return userType_driving;
    }else{
        return userType_passenger;
    }
}

- (BOOL)isUserInTravellersList:(NSString *)userId {
    for (NSString *travellerId in self.travellers_list) {
        if([userId isEqualToString:travellerId]){
            return YES;
        }
    }
    return NO;
}

- (BOOL)isUserInRequestedList:(NSString *)userId {
    for (NSString *requestedUser in self.requestedUsers) {
        if([userId isEqualToString:requestedUser]){
            return YES;
        }
    }
    return NO;
}


- (BOOL)isCurrentUserEvent {
    User *currentUser = [User currentUser];
    if ([self.userId isEqualToString:currentUser.userId]) {
        return YES;
    }else {
        return NO;
    }
}

- (BOOL)isOlderEvent{
    
    BOOL isOlder = NO;
    NSDate *eventDate = self.dateTime;
    
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval: - 2*60*60];
    NSComparisonResult result = [yesterday compare:eventDate];
    if (result == NSOrderedDescending) {
        isOlder = YES;
    }
    return isOlder;
}

- (BOOL)isActive{
    
    BOOL isActive = NO;
    
    BOOL isOlder = NO;
    BOOL isFuture = NO;
    NSDate *eventDate = self.dateTime;
    NSDate *today = [NSDate date];


    // Older
    NSDate *today_2hrs_before = [today dateByAddingTimeInterval: - 2*60*60];
    NSComparisonResult result_before = [today_2hrs_before compare:eventDate];
    if (result_before == NSOrderedDescending) {
        isOlder = YES;
    }
    
    // Future
    NSDate *today_2hrs_after = [today dateByAddingTimeInterval:2*60*60];
    NSComparisonResult result_after = [today_2hrs_after compare:eventDate];
    if (result_after == NSOrderedAscending) {
        isFuture = YES;
    }

    // Total
    if (isOlder == NO && isFuture == NO) {
        isActive = YES;
    }
    
    return isActive;
}

+ (BOOL)isAnyEventActive{
    User *currentUser = [User currentUser];
    NSArray *events = [Event eventsOfUserWithUserId:currentUser.userId];
    
    for (Event *event in events) {
        
        if ([event isUserInTravellersList:currentUser.userId] == YES &&
            [event isActive])
        {
            return YES;
        }
    }
    return NO;
}

- (void)discardUnSavedChanges {
    [[NSManagedObjectContext MR_defaultContext] refreshObject:self mergeChanges:NO];
}

#pragma mark - Sorting by date and user location

+ (NSArray *)sortEventsByLocation:(NSArray *)array{
    [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        CLLocation *currentLocation = [[TALocationManager sharedInstance] currentLocation];
        
        CLLocationCoordinate2D coordinate1 =
        CLLocationCoordinate2DMake([(Event *)obj1 sourceLatitudeValue],
                                   [(Event *)obj1 sourceLongitudeValue]);
        
        CLLocationCoordinate2D coordinate2 =
        CLLocationCoordinate2DMake([(Event *)obj2 sourceLatitudeValue],
                                   [(Event *)obj2 sourceLongitudeValue]);
        
        double distance1= [TALocationManager
                           distanceBetweenCoordinate:currentLocation.coordinate
                           andSecondCoordinate:coordinate1];
        
        double distance2= [TALocationManager
                           distanceBetweenCoordinate:currentLocation.coordinate
                           andSecondCoordinate:coordinate2];
        
        return [[NSNumber numberWithDouble:distance1] compare:[NSNumber numberWithDouble:distance2]];
    }];
    return array;
}

+ (NSArray *)sortEventsByEventDate:(NSArray *)array{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [array sortedArrayUsingDescriptors:sortDescriptors];
}

@end

@implementation travellersList

+ (Class)transformedValueClass
{
    return [NSArray class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end

@implementation requestedUsers

+ (Class)transformedValueClass
{
    return [NSArray class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end
