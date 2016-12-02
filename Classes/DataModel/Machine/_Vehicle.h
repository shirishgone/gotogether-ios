// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Vehicle.h instead.

#import <CoreData/CoreData.h>
#import "MMRecord.h"

extern const struct VehicleAttributes {
	__unsafe_unretained NSString *make;
	__unsafe_unretained NSString *model;
	__unsafe_unretained NSString *vehicleNumber;
	__unsafe_unretained NSString *verified;
} VehicleAttributes;

extern const struct VehicleRelationships {
	__unsafe_unretained NSString *user;
} VehicleRelationships;

extern const struct VehicleFetchedProperties {
} VehicleFetchedProperties;

@class User;






@interface VehicleID : NSManagedObjectID {}
@end

@interface _Vehicle : MMRecord {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (VehicleID*)objectID;





@property (nonatomic, strong) NSString* make;



//- (BOOL)validateMake:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* model;



//- (BOOL)validateModel:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* vehicleNumber;



//- (BOOL)validateVehicleNumber:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* verified;



@property BOOL verifiedValue;
- (BOOL)verifiedValue;
- (void)setVerifiedValue:(BOOL)value_;

//- (BOOL)validateVerified:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) User *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;





@end

@interface _Vehicle (CoreDataGeneratedAccessors)

@end

@interface _Vehicle (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveMake;
- (void)setPrimitiveMake:(NSString*)value;




- (NSString*)primitiveModel;
- (void)setPrimitiveModel:(NSString*)value;




- (NSString*)primitiveVehicleNumber;
- (void)setPrimitiveVehicleNumber:(NSString*)value;




- (NSNumber*)primitiveVerified;
- (void)setPrimitiveVerified:(NSNumber*)value;

- (BOOL)primitiveVerifiedValue;
- (void)setPrimitiveVerifiedValue:(BOOL)value_;





- (User*)primitiveUser;
- (void)setPrimitiveUser:(User*)value;


@end
