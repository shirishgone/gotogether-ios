#import "_Place.h"

@interface Place : _Place {}
// Custom logic goes here.
- (NSString *)displayName;
+ (Event *)cleanupPlaceNamesForEvent:(Event *)event
                         sourcePlace:(Place *)sourcePlace
                    destinationPlace:(Place *)destinationPlace;


+ (Place *)placeForLatitude:(double)latitude
                  longitude:(double)longitude
                       name:(NSString *)name;

//+ (Place *)placeWithReference:(NSString *)reference andPlaceName:(NSString *)placeName;
+ (NSArray *)allPlaces;
+ (Place *)savePlaceWithPlaceName:(NSString *)placeName
                        reference:(NSString *)reference
                         latitude:(NSNumber *)latitude
                        longitude:(NSNumber *)longitude
                  subLocalityName:(NSString *)subLocalityName
                     localityName:(NSString *)localityName
                 formattedAddress:(NSString *)formattedAddress;

@end
