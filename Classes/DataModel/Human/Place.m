#import "Place.h"


@interface Place ()
@end


@implementation Place

- (NSString *)displayName {

    NSString *displayName;
    if (self.localityName !=nil) {
        displayName = self.localityName;
    }else if (self.placeName != nil){
        displayName = self.placeName;
    }else {
        displayName = self.formattedPlaceName;
    }
    return displayName;
}

+ (Event *)cleanupPlaceNamesForEvent:(Event *)event
                         sourcePlace:(Place *)sourcePlace
                    destinationPlace:(Place *)destinationPlace{
    
    NSString *sourcePlaceName = sourcePlace.displayName;
    NSString *destinationPlaceName = destinationPlace.displayName;
    
    NSString *sourceSubLocalityName =  nil;
    if (sourcePlace.subLocalityName != nil) {
        sourceSubLocalityName = sourcePlace.subLocalityName;
    }else{
        sourceSubLocalityName = sourcePlace.placeName;
    }
    
    NSString *sourceLocalityName  = nil;
    if (sourcePlace.localityName !=nil) {
        sourceLocalityName = sourcePlace.localityName;
    }else{
        sourceLocalityName = sourcePlace.placeName;
    }
    
    
    NSString *destinationSubLocalityName =  nil;
    if (destinationPlace.subLocalityName != nil) {
        destinationSubLocalityName = destinationPlace.subLocalityName;
    }else{
        destinationSubLocalityName = destinationPlace.placeName;
    }
    
    NSString *destinationLocalityName  = nil;
    if (destinationPlace.localityName !=nil) {
        destinationLocalityName = destinationPlace.localityName;
    }else{
        destinationLocalityName = destinationPlace.placeName;
    }
    
    if ([sourceLocalityName isEqualToString:destinationLocalityName]) {
        // Both are in same city
        if ([sourceSubLocalityName isEqualToString:destinationSubLocalityName]) {
            //Both are in same area
        }else{
            //Add Sublocalityname (Area Name)
            if ([sourcePlace.subLocalityName isEqualToString:sourcePlace.placeName] == NO ) {
                if (sourcePlace.placeName != nil && sourcePlace.subLocalityName !=nil) {
                    sourcePlaceName = [NSString stringWithFormat:@"%@, %@",sourcePlace.placeName, sourcePlace.subLocalityName];
                }else if (sourcePlace.placeName == nil && sourcePlace.subLocalityName !=nil){
                    sourcePlaceName = sourcePlace.subLocalityName;
                }else{
                    sourcePlaceName = sourcePlace.displayName;
                }
            }
            if ([destinationPlace.subLocalityName isEqualToString:destinationPlace.placeName] == NO) {
                
                
                if (destinationPlace.placeName != nil && destinationPlace.subLocalityName !=nil) {
                    destinationPlaceName = [NSString stringWithFormat:@"%@, %@",destinationPlace.placeName, destinationPlace.subLocalityName];
                }else if (destinationPlace.placeName == nil && destinationPlace.subLocalityName !=nil){
                    destinationPlaceName = destinationPlace.subLocalityName;
                }else{
                    destinationPlaceName = destinationPlace.displayName;
                }
            }
        }
        
    }else{
        // Add localityname(CityName) to the place string
        if ([sourceLocalityName isEqualToString:sourcePlaceName] == NO) {
            
            if (sourcePlace.placeName != nil && sourcePlace.localityName !=nil) {
                sourcePlaceName = [NSString stringWithFormat:@"%@, %@",sourcePlace.placeName, sourcePlace.localityName];
            }else if (sourcePlace.placeName == nil && sourcePlace.localityName !=nil){
                sourcePlaceName = sourcePlace.localityName;
            }else{
                sourcePlaceName = sourcePlace.displayName;
            }
        }
        if ([destinationLocalityName isEqualToString:destinationPlaceName] == NO) {
            if (destinationPlace.placeName != nil && destinationPlace.localityName !=nil) {
                destinationPlaceName = [NSString stringWithFormat:@"%@, %@",destinationPlace.placeName, destinationPlace.localityName];
            }else if (destinationPlace.placeName == nil && destinationPlace.localityName !=nil){
                destinationPlaceName = destinationPlace.localityName;
            }else{
                destinationPlaceName = destinationPlace.displayName;
            }
        }
    }
    
    [event setSourceName:sourcePlaceName];
    [event setDestinationName:destinationPlaceName];
    
    return event;
}


+ (Place *)placeForLatitude:(double)latitude
                  longitude:(double)longitude
                       name:(NSString *)name
{
    Place *place = [Place MR_createEntity];
    [place setLatitude:[NSNumber numberWithDouble:latitude]];
    [place setLongitude:[NSNumber numberWithDouble:longitude]];
    [place setPlaceName:name];
    [[NSManagedObjectContext MR_defaultContext]
     saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
         TALog(@"Saved place to DB: %d",success);
     }];
    return place;
}

+ (Place *)placeWithReference:(NSString *)reference
                    placeName:(NSString *)placeName
                     latitude:(NSNumber *)latitude
                    longitude:(NSNumber *)longitude{

    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.reference = %@ OR self.placeName = %@ OR self.latitude = %@ OR self.longitude = %@",reference,placeName, latitude, longitude];
    Place *place = [Place MR_findFirstWithPredicate:predicate inContext:defaultContext];
    return place;
}

+ (NSArray *)allPlaces{

    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    NSArray *allPlaces = [Place MR_findAllInContext:defaultContext];
    return allPlaces;
}

+ (Place *)savePlaceWithPlaceName:(NSString *)placeName
                        reference:(NSString *)reference
                         latitude:(NSNumber *)latitude
                        longitude:(NSNumber *)longitude
                  subLocalityName:(NSString *)subLocalityName
                     localityName:(NSString *)localityName
                 formattedAddress:(NSString *)formattedAddress
{
    Place *placeObj = [Place placeWithReference:reference
                                      placeName:placeName
                                       latitude:latitude
                                      longitude:longitude
                       ];
    if(placeObj == nil){
        placeObj = [Place MR_createInContext:[NSManagedObjectContext defaultContext]];
        [placeObj setReference:reference];
    }
    [placeObj setLatitude:latitude];
    [placeObj setLongitude:longitude];
    [placeObj setPlaceName:placeName];
    [placeObj setLocalityName:localityName];
    [placeObj setSubLocalityName:subLocalityName];
    [placeObj setFormattedPlaceName:formattedAddress];
    [[NSManagedObjectContext MR_defaultContext] saveToPersistentStoreWithCompletion:nil];

    return placeObj;
}

@end
