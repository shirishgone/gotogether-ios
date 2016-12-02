// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Place.h instead.

#import <CoreData/CoreData.h>
#import "MMRecord.h"

extern const struct PlaceAttributes {
	__unsafe_unretained NSString *formattedPlaceName;
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *localityName;
	__unsafe_unretained NSString *longitude;
	__unsafe_unretained NSString *placeName;
	__unsafe_unretained NSString *reference;
	__unsafe_unretained NSString *subLocalityName;
} PlaceAttributes;

extern const struct PlaceRelationships {
} PlaceRelationships;

extern const struct PlaceFetchedProperties {
} PlaceFetchedProperties;










@interface PlaceID : NSManagedObjectID {}
@end

@interface _Place : MMRecord {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PlaceID*)objectID;





@property (nonatomic, strong) NSString* formattedPlaceName;



//- (BOOL)validateFormattedPlaceName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* latitude;



@property double latitudeValue;
- (double)latitudeValue;
- (void)setLatitudeValue:(double)value_;

//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* localityName;



//- (BOOL)validateLocalityName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* longitude;



@property double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* placeName;



//- (BOOL)validatePlaceName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* reference;



//- (BOOL)validateReference:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* subLocalityName;



//- (BOOL)validateSubLocalityName:(id*)value_ error:(NSError**)error_;






@end

@interface _Place (CoreDataGeneratedAccessors)

@end

@interface _Place (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveFormattedPlaceName;
- (void)setPrimitiveFormattedPlaceName:(NSString*)value;




- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;




- (NSString*)primitiveLocalityName;
- (void)setPrimitiveLocalityName:(NSString*)value;




- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;




- (NSString*)primitivePlaceName;
- (void)setPrimitivePlaceName:(NSString*)value;




- (NSString*)primitiveReference;
- (void)setPrimitiveReference:(NSString*)value;




- (NSString*)primitiveSubLocalityName;
- (void)setPrimitiveSubLocalityName:(NSString*)value;




@end
