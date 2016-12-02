// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Comment.h instead.

#import <CoreData/CoreData.h>
#import "MMRecord.h"

extern const struct CommentAttributes {
	__unsafe_unretained NSString *commentString;
	__unsafe_unretained NSString *commentedDate;
	__unsafe_unretained NSString *commentedUserId;
	__unsafe_unretained NSString *commentedUserName;
} CommentAttributes;

extern const struct CommentRelationships {
	__unsafe_unretained NSString *event;
} CommentRelationships;

extern const struct CommentFetchedProperties {
} CommentFetchedProperties;

@class Event;






@interface CommentID : NSManagedObjectID {}
@end

@interface _Comment : MMRecord {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CommentID*)objectID;





@property (nonatomic, strong) NSString* commentString;



//- (BOOL)validateCommentString:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* commentedDate;



//- (BOOL)validateCommentedDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* commentedUserId;



//- (BOOL)validateCommentedUserId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* commentedUserName;



//- (BOOL)validateCommentedUserName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Event *event;

//- (BOOL)validateEvent:(id*)value_ error:(NSError**)error_;





@end

@interface _Comment (CoreDataGeneratedAccessors)

@end

@interface _Comment (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCommentString;
- (void)setPrimitiveCommentString:(NSString*)value;




- (NSDate*)primitiveCommentedDate;
- (void)setPrimitiveCommentedDate:(NSDate*)value;




- (NSString*)primitiveCommentedUserId;
- (void)setPrimitiveCommentedUserId:(NSString*)value;




- (NSString*)primitiveCommentedUserName;
- (void)setPrimitiveCommentedUserName:(NSString*)value;





- (Event*)primitiveEvent;
- (void)setPrimitiveEvent:(Event*)value;


@end
