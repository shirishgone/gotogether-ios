// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Friend.h instead.

#import <CoreData/CoreData.h>
#import "MMRecord.h"

extern const struct FriendAttributes {
	__unsafe_unretained NSString *friendId;
	__unsafe_unretained NSString *friendName;
} FriendAttributes;

extern const struct FriendRelationships {
	__unsafe_unretained NSString *user;
} FriendRelationships;

extern const struct FriendFetchedProperties {
} FriendFetchedProperties;

@class User;




@interface FriendID : NSManagedObjectID {}
@end

@interface _Friend : MMRecord {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (FriendID*)objectID;





@property (nonatomic, strong) NSString* friendId;



//- (BOOL)validateFriendId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* friendName;



//- (BOOL)validateFriendName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) User *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;





@end

@interface _Friend (CoreDataGeneratedAccessors)

@end

@interface _Friend (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveFriendId;
- (void)setPrimitiveFriendId:(NSString*)value;




- (NSString*)primitiveFriendName;
- (void)setPrimitiveFriendName:(NSString*)value;





- (User*)primitiveUser;
- (void)setPrimitiveUser:(User*)value;


@end
