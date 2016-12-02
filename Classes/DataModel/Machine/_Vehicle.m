// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Vehicle.m instead.

#import "_Vehicle.h"

const struct VehicleAttributes VehicleAttributes = {
	.make = @"make",
	.model = @"model",
	.vehicleNumber = @"vehicleNumber",
	.verified = @"verified",
};

const struct VehicleRelationships VehicleRelationships = {
	.user = @"user",
};

const struct VehicleFetchedProperties VehicleFetchedProperties = {
};

@implementation VehicleID
@end

@implementation _Vehicle

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Vehicle" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Vehicle";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Vehicle" inManagedObjectContext:moc_];
}

- (VehicleID*)objectID {
	return (VehicleID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"verifiedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"verified"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic make;






@dynamic model;






@dynamic vehicleNumber;






@dynamic verified;



- (BOOL)verifiedValue {
	NSNumber *result = [self verified];
	return [result boolValue];
}

- (void)setVerifiedValue:(BOOL)value_ {
	[self setVerified:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveVerifiedValue {
	NSNumber *result = [self primitiveVerified];
	return [result boolValue];
}

- (void)setPrimitiveVerifiedValue:(BOOL)value_ {
	[self setPrimitiveVerified:[NSNumber numberWithBool:value_]];
}





@dynamic user;

	






@end
