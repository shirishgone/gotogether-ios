//
//  GTRouteMapView.m
//  goTogether
//
//  Created by Shirish on 2/11/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTRouteMapView.h"
#import <GoogleMaps/GoogleMaps.h>
#import "TALocationManager.h"
#import "TAGoogleAPIManager.h"

@interface GTRouteMapView() <GMSMapViewDelegate>
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, readwrite) CLLocationCoordinate2D source;
@property (nonatomic, readwrite) CLLocationCoordinate2D destination;
@end

@implementation GTRouteMapView

- (void)setSourceCoordinate:(CLLocationCoordinate2D)source
   andDestinationCoordinate:(CLLocationCoordinate2D)destination {
    self.source = source;
    self.destination = destination;
    [self setupMapView];
    [self fetchRoute];
}

- (void)setupMapView {
    if (self.mapView == nil) {
        self.mapView = [[GMSMapView alloc] initWithFrame:self.bounds];
        [self.mapView setDelegate:self];
        [self.mapView.settings setAllGesturesEnabled:YES];
        [self.mapView setMyLocationEnabled:YES];
        [self addSubview:_mapView];
    }
}

- (void)drawRect:(CGRect)rect {
    [self addMarkersAtSourceAndDestination];
}

#pragma mark - Add Markers

/**
 * Updates the camera position of within the map such that all the annotations (connected users' pins) are visible
 */
- (void)zoomToFitSource:(CLLocationCoordinate2D)source
            destination:(CLLocationCoordinate2D)destination
          WithZoomLevel:(float)zoomLevel {
    
    CLLocationCoordinate2D minPoint = source;
    CLLocationCoordinate2D maxPoint = destination;
    
    CLLocationCoordinate2D center =
    CLLocationCoordinate2DMake(
        minPoint.latitude + ((maxPoint.latitude - minPoint.latitude) * 0.5),
        minPoint.longitude + ((maxPoint.longitude - minPoint.longitude) * 0.5)
    );
    
    GMSCameraPosition *cameraPosition =
    [GMSCameraPosition cameraWithLatitude:center.latitude
                                longitude:center.longitude
                                     zoom:zoomLevel];
    
    [self.mapView setCamera:cameraPosition];
}

- (void)addMarkersAtSourceAndDestination {
    
    [self addMarkerAtCoordinate:self.source
                          pointerType:GTMapPointerType_Start];
    
    [self addMarkerAtCoordinate:self.destination
                          pointerType:GTMapPointerType_end];
    
    [TALocationManager fitBoundsForMarkersInMap:self.mapView];
}

- (void)addMarkerAtCoordinate:(CLLocationCoordinate2D)coordinate
                        pointerType:(GTMapPointerType)type
{
    
    CLLocationCoordinate2D position = coordinate;
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    marker.animated = YES;
    if (type == GTMapPointerType_Start) {
        marker.title = @"Start";
        marker.icon = [UIImage imageNamed:@"icon_map_start_flag"];
    }else {
        marker.title = @"End";
        marker.icon = [UIImage imageNamed:@"icon_map_end_flag"];
    }
    marker.map = self.mapView;
}

- (void)fetchRoute {
    
    if (self.routePoints != nil) {
        [self drawPathForRoutePoints:self.routePoints
                           withColor:kRouteColor_blue];
    }else{
        goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.netStatus != kNotReachable) {
            [[TAGoogleAPIManager sharedInstance]
             fetchRoutesFromCoordinate:self.source
             toCoordinate:self.destination
             ifSucess:^(NSArray *routes) {
                 if ([routes count] > 0) {
                     self.routePoints = [routes objectAtIndex:0];
                     [self drawPathForRoutePoints:self.routePoints
                                        withColor:kRouteColor_blue];
                 }

             } ifFailure:^(NSError *error) {
             }];
        }
    }
}

#pragma mark - route

- (void)drawPathForRoutePoints:(NSArray *)routePoints withColor:(UIColor *)color{
    
    GMSMutablePath *path = [GMSMutablePath path];
    for (id routePoint in routePoints) {
        CLLocation *location = routePoint;
        [path addCoordinate:location.coordinate];
    }
    
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeColor = color;
    polyline.strokeWidth = kRouteLineThickness;
    polyline.geodesic = YES;
    polyline.map = self.mapView;
}

@end
