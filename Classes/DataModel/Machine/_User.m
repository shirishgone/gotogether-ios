// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.m instead.

#import "_User.h"

const struct UserAttributes UserAttributes = {
	.accessToken = @"accessToken",
	.currentLatitude = @"currentLatitude",
	.currentLongitude = @"currentLongitude",
	.dateOfBirth = @"dateOfBirth",
	.email = @"email",
	.facebookId = @"facebookId",
	.facebookProfileLink = @"facebookProfileLink",
	.friendsList = @"friendsList",
	.gender = @"gender",
	.isVehicleAvailable = @"isVehicleAvailable",
	.mobile = @"mobile",
	.mutualFriends = @"mutualFriends",
	.name = @"name",
	.password = @"password",
	.phoneNumberVerified = @"phoneNumberVerified",
	.pictureLastModified = @"pictureLastModified",
	.profileDescription = @"profileDescription",
	.pushToken = @"pushToken",
	.rating = @"rating",
	.ratingCount = @"ratingCount",
	.userId = @"userId",
	.workPlace = @"workPlace",
};

const struct UserRelationships UserRelationships = {
	.events = @"events",
	.friends = @"friends",
	.vehicle = @"vehicle",
};

const struct UserFetchedProperties UserFetchedProperties = {
};

@implementation UserID
@end

@implementation _User

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"User";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc_];
}

- (UserID*)objectID {
	return (UserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"currentLatitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"currentLatitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"currentLongitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"currentLongitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isVehicleAvailableValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isVehicleAvailable"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"phoneNumberVerifiedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"phoneNumberVerified"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"ratingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rating"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"ratingCountValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"ratingCount"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic accessToken;






@dynamic currentLatitude;



- (double)currentLatitudeValue {
	NSNumber *result = [self currentLatitude];
	return [result doubleValue];
}

- (void)setCurrentLatitudeValue:(double)value_ {
	[self setCurrentLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveCurrentLatitudeValue {
	NSNumber *result = [self primitiveCurrentLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveCurrentLatitudeValue:(double)value_ {
	[self setPrimitiveCurrentLatitude:[NSNumber numberWithDouble:value_]];
}





@dynamic currentLongitude;



- (double)currentLongitudeValue {
	NSNumber *result = [self currentLongitude];
	return [result doubleValue];
}

- (void)setCurrentLongitudeValue:(double)value_ {
	[self setCurrentLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveCurrentLongitudeValue {
	NSNumber *result = [self primitiveCurrentLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveCurrentLongitudeValue:(double)value_ {
	[self setPrimitiveCurrentLongitude:[NSNumber numberWithDouble:value_]];
}





@dynamic dateOfBirth;






@dynamic email;






@dynamic facebookId;






@dynamic facebookProfileLink;






@dynamic friendsList;






@dynamic gender;






@dynamic isVehicleAvailable;



- (BOOL)isVehicleAvailableValue {
	NSNumber *result = [self isVehicleAvailable];
	return [result boolValue];
}

- (void)setIsVehicleAvailableValue:(BOOL)value_ {
	[self setIsVehicleAvailable:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsVehicleAvailableValue {
	NSNumber *result = [self primitiveIsVehicleAvailable];
	return [result boolValue];
}

- (void)setPrimitiveIsVehicleAvailableValue:(BOOL)value_ {
	[self setPrimitiveIsVehicleAvailable:[NSNumber numberWithBool:value_]];
}





@dynamic mobile;






@dynamic mutualFriends;






@dynamic name;






@dynamic password;






@dynamic phoneNumberVerified;



- (BOOL)phoneNumberVerifiedValue {
	NSNumber *result = [self phoneNumberVerified];
	return [result boolValue];
}

- (void)setPhoneNumberVerifiedValue:(BOOL)value_ {
	[self setPhoneNumberVerified:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitivePhoneNumberVerifiedValue {
	NSNumber *result = [self primitivePhoneNumberVerified];
	return [result boolValue];
}

- (void)setPrimitivePhoneNumberVerifiedValue:(BOOL)value_ {
	[self setPrimitivePhoneNumberVerified:[NSNumber numberWithBool:value_]];
}





@dynamic pictureLastModified;






@dynamic profileDescription;






@dynamic pushToken;






@dynamic rating;



- (float)ratingValue {
	NSNumber *result = [self rating];
	return [result floatValue];
}

- (void)setRatingValue:(float)value_ {
	[self setRating:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveRatingValue {
	NSNumber *result = [self primitiveRating];
	return [result floatValue];
}

- (void)setPrimitiveRatingValue:(float)value_ {
	[self setPrimitiveRating:[NSNumber numberWithFloat:value_]];
}





@dynamic ratingCount;



- (int16_t)ratingCountValue {
	NSNumber *result = [self ratingCount];
	return [result shortValue];
}

- (void)setRatingCountValue:(int16_t)value_ {
	[self setRatingCount:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveRatingCountValue {
	NSNumber *result = [self primitiveRatingCount];
	return [result shortValue];
}

- (void)setPrimitiveRatingCountValue:(int16_t)value_ {
	[self setPrimitiveRatingCount:[NSNumber numberWithShort:value_]];
}





@dynamic userId;






@dynamic workPlace;






@dynamic events;

	
- (NSMutableSet*)eventsSet {
	[self willAccessValueForKey:@"events"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"events"];
  
	[self didAccessValueForKey:@"events"];
	return result;
}
	

@dynamic friends;

	
- (NSMutableSet*)friendsSet {
	[self willAccessValueForKey:@"friends"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"friends"];
  
	[self didAccessValueForKey:@"friends"];
	return result;
}
	

@dynamic vehicle;

	






@end
