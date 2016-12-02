
#import "_Event.h"
#import <CoreLocation/CLLocation.h>
#import "Event.h"
#import "User.h"
#import "TARoute.h"
#import "Place.h"

@interface Event : _Event {}

#pragma mark - API Calls
+ (void)aroundMeForLatitude:(double)latitude
                  longitude:(double)longitude
                       date:(NSDate *)date
                     radius:(int)radius
                     sucess:(void(^)(NSArray *rides))handleSuccess
                    failure:(void (^)(NSError *error))handleFailure;

+ (void)searchEventForSearchType:(GTUserType)userType
                      withSource:(Place *)source
                     destination:(Place *)destination
                            date:(NSDate *)date
                          sucess:(void(^)(NSArray *rides))handleSuccess
                         failure:(void (^)(NSError *error))handleFailure;

+ (void)createEventWithDetails:(Event *)event
                        sucess:(void (^)(Event *event))handleSuccess
                       failure:(void (^)(NSError *error))handleFailure;

+ (void)editEventWithDetails:(Event *)event
                      sucess:(void (^)(Event *event))handleSuccess
                     failure:(void (^)(NSError *error))handleFailure;

+ (void)cancelEventWithDetails:(Event *)event
                        sucess:(void (^)(NSString* successMessage))handleSuccess
                       failure:(void (^)(NSError *error))handleFailure;

+ (void)bookASeatinEventWithId:(NSString *)eventId
                     seatCount:(int)seatCount
                        sucess:(void (^)(id response))handleSuccess
                       failure:(void (^)(NSError *error))handleFailure;

+ (void)confirmSeatWithEventId:(NSString *)eventId
                 requestUserId:(NSString *)requestUserId
                     seatCount:(int)seatCount
                      userType:(GTUserType)userType
                        sucess:(void (^)(id response))handleSuccess
                       failure:(void (^)(NSError *error))handleFailure;

+ (void)getEventDetailsWithEventId:(NSString *)eventId
                            sucess:(void (^)(Event *event))handleSuccess
                           failure:(void (^)(NSError *error))handleFailure;

+ (void)fetchRouteForEventId:(NSString *)eventId
                      sucess:(void (^)(NSString *routePoints))handleSuccess
                     failure:(void (^)(NSError *error))handleFailure;

+ (void)obtainRidesForUserId:(NSString *)userId
                     success:(void(^)(NSArray *response))handleSuccess
                     failure:(void(^)(NSError *error))handleFailure;

+ (void)fetchFriendFeed:(void(^)(NSArray *rides))handleSuccess
                failure:(void(^)(NSError *error))handleFailure;

+ (void)browseRidesForPage:(NSInteger)pageCount
               WithSuccess:(void(^)(NSArray *rides, NSInteger totalPages))handleSuccess
                   failure:(void(^)(NSError *error))handleFailure;


#pragma mark - Core data methods
+ (Event *)eventForEventId:(NSString *)eventid;
+ (BOOL)isEventByCurrentUser:(NSString *)eventId;
//+ (NSArray *)passengersArrayFromString:(NSString *)travellersListString;
+ (GTUserType)userTypeForString:(NSString *)userTypeString;
+ (NSString *)userTypeStringForType:(GTUserType )userType;
+ (NSArray *)eventsOfUserWithUserId:(NSString *)userId;

#pragma mark -
- (GTUserType)userTypeValue;
- (BOOL)isUserInTravellersList:(NSString *)userId;
- (BOOL)isUserInRequestedList:(NSString *)userId;
- (BOOL)isCurrentUserEvent ;
- (BOOL)isOlderEvent;
- (BOOL)isActive;
+ (BOOL)isAnyEventActive;
- (NSArray *)rideRequests;
- (BOOL)canShowNotifications;
- (void)discardUnSavedChanges;


#pragma mark - Sort methods
+ (NSArray *)sortEventsByLocation:(NSArray *)array;
+ (NSArray *)sortEventsByEventDate:(NSArray *)array;

@end

@interface requestedUsers : NSValueTransformer

@end


@interface travellersList : NSValueTransformer

@end

