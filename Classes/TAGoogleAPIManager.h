//
//  TAGoogleAPIManager.h
//  TravelApp
//
//  Created by shirish on 24/11/12.
//  Copyright (c) 2012 mutualmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "Place.h"
#import "TARoute.h"

@interface TAGoogleAPIManager : NSObject
+(TAGoogleAPIManager*)sharedInstance;

- (void)resetCurrentPlaces;
- (void)placeDetailsForReference:(NSString *)referenceString
                        ifSucess:(void(^)(id place))handlePlaceDetails
                       ifFailure:(void(^)(NSError *error))handleError ;

- (void)placesForString:(NSString *)queryString
               ifSucess:(void(^)(NSArray *places))handlePlaces
              ifFailure:(void(^)(NSError *error))handleError;


- (void)fetchLocationNameForLatitude:(CLLocationDegrees)latitude
                           longitude:(CLLocationDegrees)longitude
                            ifSucess:(void(^)(Place *place))handlePlace
                           ifFailure:(void(^)(NSError *error))handleError;

- (void)fetchRoutesFromCoordinate:(CLLocationCoordinate2D)fromLoction
                     toCoordinate:(CLLocationCoordinate2D)toLocationCoordinate
                         ifSucess:(void(^)(NSArray *routes))handleRoutes
                        ifFailure:(void(^)(NSError *error))handleError;

- (NSMutableArray *)decodePolyLine:(NSString *)encodedStr;
+ (TARoute *)routeForRoutePoints:(NSArray *)routePoints
            withSourceCoordinate:(CLLocationCoordinate2D)sourceCoordinate
           destinationCoordinate:(CLLocationCoordinate2D)destinationCoordinate;

@end
