// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Event.h instead.

#import <CoreData/CoreData.h>
#import "MMRecord.h"

extern const struct EventAttributes {
	__unsafe_unretained NSString *availableSeats;
	__unsafe_unretained NSString *createdDate;
	__unsafe_unretained NSString *dateTime;
	__unsafe_unretained NSString *destinationLatitude;
	__unsafe_unretained NSString *destinationLongitude;
	__unsafe_unretained NSString *destinationName;
	__unsafe_unretained NSString *eventId;
	__unsafe_unretained NSString *eventType;
	__unsafe_unretained NSString *requestedUserDetails;
	__unsafe_unretained NSString *requestedUsers;
	__unsafe_unretained NSString *routePoints;
	__unsafe_unretained NSString *seatPrice;
	__unsafe_unretained NSString *sourceLatitude;
	__unsafe_unretained NSString *sourceLongitude;
	__unsafe_unretained NSString *sourceName;
	__unsafe_unretained NSString *travellersListDetails;
	__unsafe_unretained NSString *travellers_list;
	__unsafe_unretained NSString *userId;
	__unsafe_unretained NSString *userName;
	__unsafe_unretained NSString *userType;
	__unsafe_unretained NSString *vehicle;
	__unsafe_unretained NSString *visibility_gender;
} EventAttributes;

extern const struct EventRelationships {
	__unsafe_unretained NSString *comments;
	__unsafe_unretained NSString *notifications;
	__unsafe_unretained NSString *user;
} EventRelationships;

extern const struct EventFetchedProperties {
} EventFetchedProperties;

@class Comment;
@class Notification;
@class User;









@class NSObject;
@class NSObject;





@class NSObject;
@class NSObject;



@class NSObject;


@interface EventID : NSManagedObjectID {}
@end

@interface _Event : MMRecord {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (EventID*)objectID;





@property (nonatomic, strong) NSNumber* availableSeats;



@property int16_t availableSeatsValue;
- (int16_t)availableSeatsValue;
- (void)setAvailableSeatsValue:(int16_t)value_;

//- (BOOL)validateAvailableSeats:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* createdDate;



//- (BOOL)validateCreatedDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateTime;



//- (BOOL)validateDateTime:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* destinationLatitude;



@property double destinationLatitudeValue;
- (double)destinationLatitudeValue;
- (void)setDestinationLatitudeValue:(double)value_;

//- (BOOL)validateDestinationLatitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* destinationLongitude;



@property double destinationLongitudeValue;
- (double)destinationLongitudeValue;
- (void)setDestinationLongitudeValue:(double)value_;

//- (BOOL)validateDestinationLongitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* destinationName;



//- (BOOL)validateDestinationName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* eventId;



//- (BOOL)validateEventId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* eventType;



//- (BOOL)validateEventType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id requestedUserDetails;



//- (BOOL)validateRequestedUserDetails:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id requestedUsers;



//- (BOOL)validateRequestedUsers:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* routePoints;



//- (BOOL)validateRoutePoints:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* seatPrice;



@property float seatPriceValue;
- (float)seatPriceValue;
- (void)setSeatPriceValue:(float)value_;

//- (BOOL)validateSeatPrice:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sourceLatitude;



@property double sourceLatitudeValue;
- (double)sourceLatitudeValue;
- (void)setSourceLatitudeValue:(double)value_;

//- (BOOL)validateSourceLatitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sourceLongitude;



@property double sourceLongitudeValue;
- (double)sourceLongitudeValue;
- (void)setSourceLongitudeValue:(double)value_;

//- (BOOL)validateSourceLongitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* sourceName;



//- (BOOL)validateSourceName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id travellersListDetails;



//- (BOOL)validateTravellersListDetails:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id travellers_list;



//- (BOOL)validateTravellers_list:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* userId;



//- (BOOL)validateUserId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* userName;



//- (BOOL)validateUserName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* userType;



//- (BOOL)validateUserType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id vehicle;



//- (BOOL)validateVehicle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* visibility_gender;



//- (BOOL)validateVisibility_gender:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *comments;

- (NSMutableSet*)commentsSet;




@property (nonatomic, strong) NSSet *notifications;

- (NSMutableSet*)notificationsSet;




@property (nonatomic, strong) User *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;





@end

@interface _Event (CoreDataGeneratedAccessors)

- (void)addComments:(NSSet*)value_;
- (void)removeComments:(NSSet*)value_;
- (void)addCommentsObject:(Comment*)value_;
- (void)removeCommentsObject:(Comment*)value_;

- (void)addNotifications:(NSSet*)value_;
- (void)removeNotifications:(NSSet*)value_;
- (void)addNotificationsObject:(Notification*)value_;
- (void)removeNotificationsObject:(Notification*)value_;

@end

@interface _Event (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveAvailableSeats;
- (void)setPrimitiveAvailableSeats:(NSNumber*)value;

- (int16_t)primitiveAvailableSeatsValue;
- (void)setPrimitiveAvailableSeatsValue:(int16_t)value_;




- (NSDate*)primitiveCreatedDate;
- (void)setPrimitiveCreatedDate:(NSDate*)value;




- (NSDate*)primitiveDateTime;
- (void)setPrimitiveDateTime:(NSDate*)value;




- (NSNumber*)primitiveDestinationLatitude;
- (void)setPrimitiveDestinationLatitude:(NSNumber*)value;

- (double)primitiveDestinationLatitudeValue;
- (void)setPrimitiveDestinationLatitudeValue:(double)value_;




- (NSNumber*)primitiveDestinationLongitude;
- (void)setPrimitiveDestinationLongitude:(NSNumber*)value;

- (double)primitiveDestinationLongitudeValue;
- (void)setPrimitiveDestinationLongitudeValue:(double)value_;




- (NSString*)primitiveDestinationName;
- (void)setPrimitiveDestinationName:(NSString*)value;




- (NSString*)primitiveEventId;
- (void)setPrimitiveEventId:(NSString*)value;




- (NSString*)primitiveEventType;
- (void)setPrimitiveEventType:(NSString*)value;




- (id)primitiveRequestedUserDetails;
- (void)setPrimitiveRequestedUserDetails:(id)value;




- (id)primitiveRequestedUsers;
- (void)setPrimitiveRequestedUsers:(id)value;




- (NSString*)primitiveRoutePoints;
- (void)setPrimitiveRoutePoints:(NSString*)value;




- (NSNumber*)primitiveSeatPrice;
- (void)setPrimitiveSeatPrice:(NSNumber*)value;

- (float)primitiveSeatPriceValue;
- (void)setPrimitiveSeatPriceValue:(float)value_;




- (NSNumber*)primitiveSourceLatitude;
- (void)setPrimitiveSourceLatitude:(NSNumber*)value;

- (double)primitiveSourceLatitudeValue;
- (void)setPrimitiveSourceLatitudeValue:(double)value_;




- (NSNumber*)primitiveSourceLongitude;
- (void)setPrimitiveSourceLongitude:(NSNumber*)value;

- (double)primitiveSourceLongitudeValue;
- (void)setPrimitiveSourceLongitudeValue:(double)value_;




- (NSString*)primitiveSourceName;
- (void)setPrimitiveSourceName:(NSString*)value;




- (id)primitiveTravellersListDetails;
- (void)setPrimitiveTravellersListDetails:(id)value;




- (id)primitiveTravellers_list;
- (void)setPrimitiveTravellers_list:(id)value;




- (NSString*)primitiveUserId;
- (void)setPrimitiveUserId:(NSString*)value;




- (NSString*)primitiveUserName;
- (void)setPrimitiveUserName:(NSString*)value;




- (NSString*)primitiveUserType;
- (void)setPrimitiveUserType:(NSString*)value;




- (id)primitiveVehicle;
- (void)setPrimitiveVehicle:(id)value;




- (NSString*)primitiveVisibility_gender;
- (void)setPrimitiveVisibility_gender:(NSString*)value;





- (NSMutableSet*)primitiveComments;
- (void)setPrimitiveComments:(NSMutableSet*)value;



- (NSMutableSet*)primitiveNotifications;
- (void)setPrimitiveNotifications:(NSMutableSet*)value;



- (User*)primitiveUser;
- (void)setPrimitiveUser:(User*)value;


@end
