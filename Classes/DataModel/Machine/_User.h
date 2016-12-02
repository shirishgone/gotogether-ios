// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.h instead.

#import <CoreData/CoreData.h>
#import "MMRecord.h"

extern const struct UserAttributes {
	__unsafe_unretained NSString *accessToken;
	__unsafe_unretained NSString *currentLatitude;
	__unsafe_unretained NSString *currentLongitude;
	__unsafe_unretained NSString *dateOfBirth;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *facebookId;
	__unsafe_unretained NSString *facebookProfileLink;
	__unsafe_unretained NSString *friendsList;
	__unsafe_unretained NSString *gender;
	__unsafe_unretained NSString *isVehicleAvailable;
	__unsafe_unretained NSString *mobile;
	__unsafe_unretained NSString *mutualFriends;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *password;
	__unsafe_unretained NSString *phoneNumberVerified;
	__unsafe_unretained NSString *pictureLastModified;
	__unsafe_unretained NSString *profileDescription;
	__unsafe_unretained NSString *pushToken;
	__unsafe_unretained NSString *rating;
	__unsafe_unretained NSString *ratingCount;
	__unsafe_unretained NSString *userId;
	__unsafe_unretained NSString *workPlace;
} UserAttributes;

extern const struct UserRelationships {
	__unsafe_unretained NSString *events;
	__unsafe_unretained NSString *friends;
	__unsafe_unretained NSString *vehicle;
} UserRelationships;

extern const struct UserFetchedProperties {
} UserFetchedProperties;

@class Event;
@class Friend;
@class Vehicle;












@class NSObject;











@interface UserID : NSManagedObjectID {}
@end

@interface _User : MMRecord {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UserID*)objectID;





@property (nonatomic, strong) NSString* accessToken;



//- (BOOL)validateAccessToken:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* currentLatitude;



@property double currentLatitudeValue;
- (double)currentLatitudeValue;
- (void)setCurrentLatitudeValue:(double)value_;

//- (BOOL)validateCurrentLatitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* currentLongitude;



@property double currentLongitudeValue;
- (double)currentLongitudeValue;
- (void)setCurrentLongitudeValue:(double)value_;

//- (BOOL)validateCurrentLongitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* dateOfBirth;



//- (BOOL)validateDateOfBirth:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* facebookId;



//- (BOOL)validateFacebookId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* facebookProfileLink;



//- (BOOL)validateFacebookProfileLink:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* friendsList;



//- (BOOL)validateFriendsList:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* gender;



//- (BOOL)validateGender:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isVehicleAvailable;



@property BOOL isVehicleAvailableValue;
- (BOOL)isVehicleAvailableValue;
- (void)setIsVehicleAvailableValue:(BOOL)value_;

//- (BOOL)validateIsVehicleAvailable:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* mobile;



//- (BOOL)validateMobile:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) id mutualFriends;



//- (BOOL)validateMutualFriends:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* password;



//- (BOOL)validatePassword:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* phoneNumberVerified;



@property BOOL phoneNumberVerifiedValue;
- (BOOL)phoneNumberVerifiedValue;
- (void)setPhoneNumberVerifiedValue:(BOOL)value_;

//- (BOOL)validatePhoneNumberVerified:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* pictureLastModified;



//- (BOOL)validatePictureLastModified:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* profileDescription;



//- (BOOL)validateProfileDescription:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* pushToken;



//- (BOOL)validatePushToken:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* rating;



@property float ratingValue;
- (float)ratingValue;
- (void)setRatingValue:(float)value_;

//- (BOOL)validateRating:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* ratingCount;



@property int16_t ratingCountValue;
- (int16_t)ratingCountValue;
- (void)setRatingCountValue:(int16_t)value_;

//- (BOOL)validateRatingCount:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* userId;



//- (BOOL)validateUserId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* workPlace;



//- (BOOL)validateWorkPlace:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *events;

- (NSMutableSet*)eventsSet;




@property (nonatomic, strong) NSSet *friends;

- (NSMutableSet*)friendsSet;




@property (nonatomic, strong) Vehicle *vehicle;

//- (BOOL)validateVehicle:(id*)value_ error:(NSError**)error_;





@end

@interface _User (CoreDataGeneratedAccessors)

- (void)addEvents:(NSSet*)value_;
- (void)removeEvents:(NSSet*)value_;
- (void)addEventsObject:(Event*)value_;
- (void)removeEventsObject:(Event*)value_;

- (void)addFriends:(NSSet*)value_;
- (void)removeFriends:(NSSet*)value_;
- (void)addFriendsObject:(Friend*)value_;
- (void)removeFriendsObject:(Friend*)value_;

@end

@interface _User (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAccessToken;
- (void)setPrimitiveAccessToken:(NSString*)value;




- (NSNumber*)primitiveCurrentLatitude;
- (void)setPrimitiveCurrentLatitude:(NSNumber*)value;

- (double)primitiveCurrentLatitudeValue;
- (void)setPrimitiveCurrentLatitudeValue:(double)value_;




- (NSNumber*)primitiveCurrentLongitude;
- (void)setPrimitiveCurrentLongitude:(NSNumber*)value;

- (double)primitiveCurrentLongitudeValue;
- (void)setPrimitiveCurrentLongitudeValue:(double)value_;




- (NSDate*)primitiveDateOfBirth;
- (void)setPrimitiveDateOfBirth:(NSDate*)value;




- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSString*)primitiveFacebookId;
- (void)setPrimitiveFacebookId:(NSString*)value;




- (NSString*)primitiveFacebookProfileLink;
- (void)setPrimitiveFacebookProfileLink:(NSString*)value;




- (NSString*)primitiveFriendsList;
- (void)setPrimitiveFriendsList:(NSString*)value;




- (NSString*)primitiveGender;
- (void)setPrimitiveGender:(NSString*)value;




- (NSNumber*)primitiveIsVehicleAvailable;
- (void)setPrimitiveIsVehicleAvailable:(NSNumber*)value;

- (BOOL)primitiveIsVehicleAvailableValue;
- (void)setPrimitiveIsVehicleAvailableValue:(BOOL)value_;




- (NSString*)primitiveMobile;
- (void)setPrimitiveMobile:(NSString*)value;




- (id)primitiveMutualFriends;
- (void)setPrimitiveMutualFriends:(id)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitivePassword;
- (void)setPrimitivePassword:(NSString*)value;




- (NSNumber*)primitivePhoneNumberVerified;
- (void)setPrimitivePhoneNumberVerified:(NSNumber*)value;

- (BOOL)primitivePhoneNumberVerifiedValue;
- (void)setPrimitivePhoneNumberVerifiedValue:(BOOL)value_;




- (NSDate*)primitivePictureLastModified;
- (void)setPrimitivePictureLastModified:(NSDate*)value;




- (NSString*)primitiveProfileDescription;
- (void)setPrimitiveProfileDescription:(NSString*)value;




- (NSString*)primitivePushToken;
- (void)setPrimitivePushToken:(NSString*)value;




- (NSNumber*)primitiveRating;
- (void)setPrimitiveRating:(NSNumber*)value;

- (float)primitiveRatingValue;
- (void)setPrimitiveRatingValue:(float)value_;




- (NSNumber*)primitiveRatingCount;
- (void)setPrimitiveRatingCount:(NSNumber*)value;

- (int16_t)primitiveRatingCountValue;
- (void)setPrimitiveRatingCountValue:(int16_t)value_;




- (NSString*)primitiveUserId;
- (void)setPrimitiveUserId:(NSString*)value;




- (NSString*)primitiveWorkPlace;
- (void)setPrimitiveWorkPlace:(NSString*)value;





- (NSMutableSet*)primitiveEvents;
- (void)setPrimitiveEvents:(NSMutableSet*)value;



- (NSMutableSet*)primitiveFriends;
- (void)setPrimitiveFriends:(NSMutableSet*)value;



- (Vehicle*)primitiveVehicle;
- (void)setPrimitiveVehicle:(Vehicle*)value;


@end
