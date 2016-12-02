//
//  TALocationManager.m
//  goTogether
//
//  Created by shirish on 29/01/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "TALocationManager.h"
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import "TAGoogleAPIManager.h"
#import <GoogleMaps/GoogleMaps.h>
#import "SIAlertView.h"
#import "GTNotificationsManager.h"

#define GTLOCATION_DISTANCEFILTER_ACTIVESTATE 1000.0f

static TALocationManager *sharedInstance = nil;
@interface TALocationManager() <CLLocationManagerDelegate>
@property (nonatomic, strong) NSDate *locationManagerStartDate;
@property (nonatomic, strong) SIAlertView *locationServicesAlert;
@end

@implementation TALocationManager

+(TALocationManager*)sharedInstance
{
    @synchronized([TAGoogleAPIManager class])
    {
        if (!sharedInstance){
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
    return nil;
}

- (id)init {
    if (self = [super init]) {        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
        [_locationManager setDistanceFilter:GTLOCATION_DISTANCEFILTER_ACTIVESTATE];
        _locationManagerStartDate = [NSDate date];
    }
    return self;
}

#pragma mark - Location Services Start/Stop

- (void)startLocationManager {
    static int retryNumber = 0;
    
    // This method can be hit before the location manager is initialized.
    if (_locationManager == nil) {
        retryNumber++;
        
        if (retryNumber < 5) {
            double delayInSeconds = 0.2f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self startLocationManager];
            });
            return;
        }
    }
    
    retryNumber = 0;
    TALog(@"STARTING LOCATION SERVICES");
        
    if([CLLocationManager locationServicesEnabled]) {
        if([self isLocationAccessGranted]) {
            [_locationManager startUpdatingLocation];
        } else{
            [self requestLocationAccess];
        }
    } else {
//        goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)
//        [[UIApplication sharedApplication] delegate];
//        GTRootViewController *rootViewController = [appDelegate rootViewController];
//        [rootViewController showLocationDisabledAlert];
    }
}

- (void)requestLocationAccess {
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self.locationManager requestWhenInUseAuthorization];
    }else {
        [self.locationManager requestAlwaysAuthorization];
    }
}

- (BOOL)isLocationAccessGranted {
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorized || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {

    if ([self isValidLocation:newLocation withOldLocation:_currentLocation] == YES) {
        
        _currentLocation = [newLocation copy];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kNotificationType_locationUpdated
         object:nil];
    }
}

- (BOOL)isValidLocation:(CLLocation *)newLocation
        withOldLocation:(CLLocation *)oldLocation
{
    // Filter out nil locations
    if (!newLocation)
    {
        return NO;
    }
    
    // Filter out points by invalid accuracy
    if (newLocation.horizontalAccuracy < 0)
    {
        return NO;
    }
    
    // Filter out points created before the manager was initialized
    NSTimeInterval secondsSinceManagerStarted =
    [newLocation.timestamp timeIntervalSinceDate:_locationManagerStartDate];
    
    if (secondsSinceManagerStarted < 0)
    {
        return NO;
    }

    // Filter out points that are out of order
    NSTimeInterval secondsSinceLastPoint =
    [newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp];
    
    if (secondsSinceLastPoint < 90)
    {
        return NO;
    }
    
    float newLocation_latitude = floorf(newLocation.coordinate.latitude * 1000 + 0.5) / 1000;  /* Decimal upto 3 points*/
    float newLocation_longitude = floorf(newLocation.coordinate.longitude * 1000 + 0.5) / 1000;
    
    float currentLocation_latitude = floorf(_currentLocation.coordinate.latitude * 1000 + 0.5) / 1000;
    float currentLocation_longitude = floorf(_currentLocation.coordinate.longitude * 1000 + 0.5) / 1000;
    
    TALog(@"new location (%f,%f)",newLocation_latitude,newLocation_longitude);
    TALog(@"current location latitude: (%f,%f)",currentLocation_latitude,currentLocation_longitude);
    
    if (currentLocation_latitude == newLocation_latitude &&
        currentLocation_longitude == newLocation_longitude) {
        return NO;
    }

    // The newLocation is good to use
    return YES;
}


- (void)stopUpdatingLocationManager{
    [_locationManager stopUpdatingLocation];
}

#pragma mark - zoom level methods
- (float)zoomLevelForDistance:(double)distance{

    float zoomLevel = kGMSMaxZoomLevel;
    
    distance = distance/1000; // Convert to KM
    if (distance < 5) {
        zoomLevel = 14.0;
    }else if (distance < 10){
        zoomLevel = 13.5;
    }else if (distance < 25){
        zoomLevel = 13.0;
    }else if (distance < 50){
        zoomLevel = 12.0;
    }else if (distance < 100){
        zoomLevel = 10.0;
    }else if (distance < 500){
        zoomLevel = 8.0;
    }else{
        zoomLevel = 6.0;
    }
    return zoomLevel;
}

- (float)defaultZoomLevel{
    float zoomLevel = kGMSMaxZoomLevel - 5;
    return zoomLevel;
}

+ (double)costPerDistance:(double)distance{
    double distanceInKm = distance/kMetersToKiloMeters;
    double cost = 1.5* distanceInKm;

    cost = round(cost/10) *10;
    return cost;
}

+ (double)distanceBetweenCoordinate:(CLLocationCoordinate2D )firstCoordinate
                andSecondCoordinate:(CLLocationCoordinate2D )secondCoordinate{
    
    CLLocation *firstLocation = [[CLLocation alloc]
                                 initWithLatitude:firstCoordinate.latitude
                                 longitude:firstCoordinate.longitude
                                 ];

    CLLocation *secondLocation = [[CLLocation alloc]
                                 initWithLatitude:secondCoordinate.latitude
                                 longitude:secondCoordinate.longitude
                                 ];

    double distance = [firstLocation distanceFromLocation:secondLocation];
    return distance;
}

+ (void)openSettingsForPermission{

    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"prefs:root=LOCATION_SERVICES"]];
}

+ (void)fitBoundsForMarkersInMap:(GMSMapView *)mapView
{
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];;
    
    for (GMSMarker *marker in mapView.markers) {
        bounds = [bounds includingCoordinate:marker.position];
    }
    
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds];
    [mapView moveCamera:update];
    [mapView animateToViewingAngle:45];
}

@end
