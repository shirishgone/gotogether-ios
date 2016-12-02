// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Event.m instead.

#import "_Event.h"

const struct EventAttributes EventAttributes = {
	.availableSeats = @"availableSeats",
	.createdDate = @"createdDate",
	.dateTime = @"dateTime",
	.destinationLatitude = @"destinationLatitude",
	.destinationLongitude = @"destinationLongitude",
	.destinationName = @"destinationName",
	.eventId = @"eventId",
	.eventType = @"eventType",
	.requestedUserDetails = @"requestedUserDetails",
	.requestedUsers = @"requestedUsers",
	.routePoints = @"routePoints",
	.seatPrice = @"seatPrice",
	.sourceLatitude = @"sourceLatitude",
	.sourceLongitude = @"sourceLongitude",
	.sourceName = @"sourceName",
	.travellersListDetails = @"travellersListDetails",
	.travellers_list = @"travellers_list",
	.userId = @"userId",
	.userName = @"userName",
	.userType = @"userType",
	.vehicle = @"vehicle",
	.visibility_gender = @"visibility_gender",
};

const struct EventRelationships EventRelationships = {
	.comments = @"comments",
	.notifications = @"notifications",
	.user = @"user",
};

const struct EventFetchedProperties EventFetchedProperties = {
};

@implementation EventID
@end

@implementation _Event

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Event";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Event" inManagedObjectContext:moc_];
}

- (EventID*)objectID {
	return (EventID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"availableSeatsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"availableSeats"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"destinationLatitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"destinationLatitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"destinationLongitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"destinationLongitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"seatPriceValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"seatPrice"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sourceLatitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sourceLatitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sourceLongitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sourceLongitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic availableSeats;



- (int16_t)availableSeatsValue {
	NSNumber *result = [self availableSeats];
	return [result shortValue];
}

- (void)setAvailableSeatsValue:(int16_t)value_ {
	[self setAvailableSeats:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveAvailableSeatsValue {
	NSNumber *result = [self primitiveAvailableSeats];
	return [result shortValue];
}

- (void)setPrimitiveAvailableSeatsValue:(int16_t)value_ {
	[self setPrimitiveAvailableSeats:[NSNumber numberWithShort:value_]];
}





@dynamic createdDate;






@dynamic dateTime;






@dynamic destinationLatitude;



- (double)destinationLatitudeValue {
	NSNumber *result = [self destinationLatitude];
	return [result doubleValue];
}

- (void)setDestinationLatitudeValue:(double)value_ {
	[self setDestinationLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveDestinationLatitudeValue {
	NSNumber *result = [self primitiveDestinationLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveDestinationLatitudeValue:(double)value_ {
	[self setPrimitiveDestinationLatitude:[NSNumber numberWithDouble:value_]];
}





@dynamic destinationLongitude;



- (double)destinationLongitudeValue {
	NSNumber *result = [self destinationLongitude];
	return [result doubleValue];
}

- (void)setDestinationLongitudeValue:(double)value_ {
	[self setDestinationLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveDestinationLongitudeValue {
	NSNumber *result = [self primitiveDestinationLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveDestinationLongitudeValue:(double)value_ {
	[self setPrimitiveDestinationLongitude:[NSNumber numberWithDouble:value_]];
}





@dynamic destinationName;






@dynamic eventId;






@dynamic eventType;






@dynamic requestedUserDetails;






@dynamic requestedUsers;






@dynamic routePoints;






@dynamic seatPrice;



- (float)seatPriceValue {
	NSNumber *result = [self seatPrice];
	return [result floatValue];
}

- (void)setSeatPriceValue:(float)value_ {
	[self setSeatPrice:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveSeatPriceValue {
	NSNumber *result = [self primitiveSeatPrice];
	return [result floatValue];
}

- (void)setPrimitiveSeatPriceValue:(float)value_ {
	[self setPrimitiveSeatPrice:[NSNumber numberWithFloat:value_]];
}





@dynamic sourceLatitude;



- (double)sourceLatitudeValue {
	NSNumber *result = [self sourceLatitude];
	return [result doubleValue];
}

- (void)setSourceLatitudeValue:(double)value_ {
	[self setSourceLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveSourceLatitudeValue {
	NSNumber *result = [self primitiveSourceLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveSourceLatitudeValue:(double)value_ {
	[self setPrimitiveSourceLatitude:[NSNumber numberWithDouble:value_]];
}





@dynamic sourceLongitude;



- (double)sourceLongitudeValue {
	NSNumber *result = [self sourceLongitude];
	return [result doubleValue];
}

- (void)setSourceLongitudeValue:(double)value_ {
	[self setSourceLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveSourceLongitudeValue {
	NSNumber *result = [self primitiveSourceLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveSourceLongitudeValue:(double)value_ {
	[self setPrimitiveSourceLongitude:[NSNumber numberWithDouble:value_]];
}





@dynamic sourceName;






@dynamic travellersListDetails;






@dynamic travellers_list;






@dynamic userId;






@dynamic userName;






@dynamic userType;






@dynamic vehicle;






@dynamic visibility_gender;






@dynamic comments;

	
- (NSMutableSet*)commentsSet {
	[self willAccessValueForKey:@"comments"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"comments"];
  
	[self didAccessValueForKey:@"comments"];
	return result;
}
	

@dynamic notifications;

	
- (NSMutableSet*)notificationsSet {
	[self willAccessValueForKey:@"notifications"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"notifications"];
  
	[self didAccessValueForKey:@"notifications"];
	return result;
}
	

@dynamic user;

	






@end
