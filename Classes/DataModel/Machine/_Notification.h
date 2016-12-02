// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Notification.h instead.

#import <CoreData/CoreData.h>
#import "MMRecord.h"

extern const struct NotificationAttributes {
	__unsafe_unretained NSString *alertMessage;
	__unsafe_unretained NSString *date;
	__unsafe_unretained NSString *eventId;
	__unsafe_unretained NSString *read;
	__unsafe_unretained NSString *type;
	__unsafe_unretained NSString *userId;
} NotificationAttributes;

extern const struct NotificationRelationships {
	__unsafe_unretained NSString *event;
} NotificationRelationships;

extern const struct NotificationFetchedProperties {
} NotificationFetchedProperties;

@class Event;








@interface NotificationID : NSManagedObjectID {}
@end

@interface _Notification : MMRecord {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (NotificationID*)objectID;





@property (nonatomic, strong) NSString* alertMessage;



//- (BOOL)validateAlertMessage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* date;



//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* eventId;



//- (BOOL)validateEventId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* read;



@property BOOL readValue;
- (BOOL)readValue;
- (void)setReadValue:(BOOL)value_;

//- (BOOL)validateRead:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* type;



//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* userId;



//- (BOOL)validateUserId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Event *event;

//- (BOOL)validateEvent:(id*)value_ error:(NSError**)error_;





@end

@interface _Notification (CoreDataGeneratedAccessors)

@end

@interface _Notification (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAlertMessage;
- (void)setPrimitiveAlertMessage:(NSString*)value;




- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;




- (NSString*)primitiveEventId;
- (void)setPrimitiveEventId:(NSString*)value;




- (NSNumber*)primitiveRead;
- (void)setPrimitiveRead:(NSNumber*)value;

- (BOOL)primitiveReadValue;
- (void)setPrimitiveReadValue:(BOOL)value_;




- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;




- (NSString*)primitiveUserId;
- (void)setPrimitiveUserId:(NSString*)value;





- (Event*)primitiveEvent;
- (void)setPrimitiveEvent:(Event*)value;


@end
