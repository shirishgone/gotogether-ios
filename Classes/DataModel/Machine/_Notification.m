// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Notification.m instead.

#import "_Notification.h"

const struct NotificationAttributes NotificationAttributes = {
	.alertMessage = @"alertMessage",
	.date = @"date",
	.eventId = @"eventId",
	.read = @"read",
	.type = @"type",
	.userId = @"userId",
};

const struct NotificationRelationships NotificationRelationships = {
	.event = @"event",
};

const struct NotificationFetchedProperties NotificationFetchedProperties = {
};

@implementation NotificationID
@end

@implementation _Notification

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Notification" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Notification";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Notification" inManagedObjectContext:moc_];
}

- (NotificationID*)objectID {
	return (NotificationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"readValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"read"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic alertMessage;






@dynamic date;






@dynamic eventId;






@dynamic read;



- (BOOL)readValue {
	NSNumber *result = [self read];
	return [result boolValue];
}

- (void)setReadValue:(BOOL)value_ {
	[self setRead:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveReadValue {
	NSNumber *result = [self primitiveRead];
	return [result boolValue];
}

- (void)setPrimitiveReadValue:(BOOL)value_ {
	[self setPrimitiveRead:[NSNumber numberWithBool:value_]];
}





@dynamic type;






@dynamic userId;






@dynamic event;

	






@end
