//
//  TALocationManager.h
//  goTogether
//
//  Created by shirish on 29/01/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface TALocationManager : NSObject
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) NSString *currentUserLocationName;
@property (nonatomic, strong) CLLocationManager *locationManager;

+ (TALocationManager*)sharedInstance;
- (void)startLocationManager;
- (void)stopUpdatingLocationManager;

- (BOOL)isLocationAccessGranted;

+ (double)distanceBetweenCoordinate:(CLLocationCoordinate2D )firstCoordinate
                andSecondCoordinate:(CLLocationCoordinate2D )secondCoordinate;
+ (double)costPerDistance:(double)distance;
+ (void)fitBoundsForMarkersInMap:(GMSMapView *)mapView;

#pragma mark - zoom level
- (float)zoomLevelForDistance:(double)distance;
- (float)defaultZoomLevel;

@end
