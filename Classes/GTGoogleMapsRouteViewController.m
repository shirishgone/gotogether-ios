//
//  TAGoogleMapsRouteViewController.m
//  goTogether
//
//  Created by shirish on 07/03/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTGoogleMapsRouteViewController.h"
#import "TAGoogleAPIManager.h"
#import "TARoute.h"
#import "Place.h"
#import "goTogetherAppDelegate.h"
#import "TALocationManager.h"
#import "UIImage+TAExtensions.h"
#import "GTPlacesManager.h"

@interface GTGoogleMapsRouteViewController ()<GMSMapViewDelegate>

#pragma mark - data properties
@property (nonatomic, strong) TARoute *userRoute;
@property (nonatomic, strong) Place *sourcePlace;
@property (nonatomic, strong) Place *destinationPlace;
@property (nonatomic, strong) NSTimer *timer;

#pragma mark - view properties
@property (weak, nonatomic) IBOutlet UIImageView *bottomBar;
@property (nonatomic, weak) IBOutlet UIButton *blueButton;
@property (nonatomic, weak) IBOutlet UIButton *greenButton;
@property (nonatomic, weak) IBOutlet UIButton *redButton;
- (IBAction)routeSelectedWithButton:(id)sender;
@end

@implementation GTGoogleMapsRouteViewController

#pragma mark - TAGoogleMapsOpenMode_showRoute

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupMap];
    [self addMarkersAtSourceAndDestination];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_mode == TAGoogleMapsOpenMode_routeSelection) {
        self.title = @"Select Route";
    }else{
        self.title = @"Route";
        if ([self canShowTravellersOnMap]){
            [self addTravellersMarkers];
            [self addTimerToRefresh];
        }
        
        [self removeRouteSelectionView];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self trackScreenName:@"RouteMap"];
    if (_mode == TAGoogleMapsOpenMode_routeSelection) {
        if (self.routes == nil) {
            [self fetchRoutesAndDrawForMode:_mode];
        }else{
            [self drawRoutes];
        }
    }else{
        [self fetchUserRouteForEvent:self.event];
    }

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [[GTPlacesManager sharedInstance] cleanupTemporaryContext];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)setIsPresented:(BOOL)isPresented{
    _isPresented = isPresented;
    if (isPresented) {
        [self addCloseButton];
    }
}

- (void)addCloseButton{
    UIImage *closeButtonImage = [UIImage imageNamed:@"btn_decline_normal"];
    UIButton *closeButton = [[UIButton alloc]
                             initWithFrame:CGRectMake(270.0,
                                                      40.0,
                                                      closeButtonImage.size.width,
                                                      closeButtonImage.size.height)];
    [closeButton setImage:closeButtonImage forState:UIControlStateNormal];
    [closeButton addTarget:self
                    action:@selector(closeButtonTouched)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
}

- (void)closeButtonTouched{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupMap{
    _mapView.myLocationEnabled = YES;
    _mapView.delegate = self;
    [_mapView setMapType:kGMSTypeNormal];
}

- (void)setEvent:(Event *)event{
    _event = event;

    self.sourcePlace = [[GTPlacesManager sharedInstance] temporaryPlace];
    [_sourcePlace setPlaceName:_event.sourceName];
    [_sourcePlace setLatitude:_event.sourceLatitude];
    [_sourcePlace setLongitude:_event.sourceLongitude];
    
    self.destinationPlace = [[GTPlacesManager sharedInstance] temporaryPlace];
    [_destinationPlace setPlaceName:_event.destinationName];
    [_destinationPlace setLatitude:_event.destinationLatitude];
    [_destinationPlace setLongitude:_event.destinationLongitude];

}

#pragma mark - Show Travellers

- (void)addTravellersMarkers{
   
    NSArray *travellers = [self.event travellers_list];
    for (NSString *travellerId in travellers) {
//        User *traveller = [User userForUserId:travellerId];
        
        [self addUserMarkerForuser:travellerId];
    }
}

- (void)updateTravellersLocation{
    
    NSArray *userMarkers = [self.mapView markers];
    NSArray *travellers = [self.event travellers_list];

    for (NSString *travellerId in travellers) {
        
        [User
         fetchUserLocationWithUserId:travellerId
         sucess:^(CLLocationCoordinate2D coordinate) {
             for (GMSMarker *userMarker in userMarkers) {
                 if([userMarker.userData isEqual:travellerId]){
                     [userMarker setPosition:coordinate];
                     break;
                 }
             }
         } failure:^(NSError *error) {
             TALog(@"error: %@ updating user location",error);
         }];
    }
}

- (BOOL)canShowTravellersOnMap{
    
    User *currentUser = [User currentUser];
    if ([self.event isActive] == YES &&
        [self.event isUserInTravellersList:currentUser.userId]== YES) {
        
        return YES;
    }else{
        return NO;
    }
}

- (void)addTimerToRefresh{

    self.timer=
    [NSTimer
     scheduledTimerWithTimeInterval: 60.0
     target: self
     selector:@selector(updateTravellersLocation)
     userInfo: nil
     repeats:YES];

    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:_timer forMode: NSDefaultRunLoopMode];
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
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(
                                                               minPoint.latitude + ((maxPoint.latitude - minPoint.latitude) * 0.5),
                                                               minPoint.longitude + ((maxPoint.longitude - minPoint.longitude) * 0.5)
                                                               );
    
    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:center.latitude longitude:center.longitude zoom:zoomLevel];
    
    [self.mapView setCamera:cameraPosition];
}

- (void)addMarkersAtSourceAndDestination{
    
    CLLocationCoordinate2D sourceCoordinate =
    CLLocationCoordinate2DMake(_sourcePlace.latitudeValue,
                               _sourcePlace.longitudeValue);
    CLLocationCoordinate2D destinationCoordinate =
    CLLocationCoordinate2DMake(_destinationPlace.latitudeValue,
                               _destinationPlace.longitudeValue);

    [self addMarkerAtCoordinate:sourceCoordinate
                          title:_sourcePlace.displayName];
    
    [self addMarkerAtCoordinate:destinationCoordinate
                          title:_destinationPlace.displayName];
    
    [TALocationManager fitBoundsForMarkersInMap:self.mapView];
}

- (void)addMarkerAtCoordinate:(CLLocationCoordinate2D)coordinate
                         title:(NSString *)title
{
    
    CLLocationCoordinate2D position = coordinate;
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    marker.title = title;
    marker.animated = YES;
    marker.map = self.mapView;
}

#pragma mark - User Marker with Picture
- (BOOL)doesReachDestinationForCoordinate:(CLLocationCoordinate2D) coordinate{
//TODO:
    return NO;
}

- (void)addUserMarkerForuser:(NSString *)userId{
    
    [User
     fetchUserLocationWithUserId:userId
     sucess:^(CLLocationCoordinate2D coordinate) {
         
         if ([self doesReachDestinationForCoordinate:coordinate] == NO) {
             GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
             marker.title = [User userNameForEmailId:userId];
             marker.animated = YES;
             marker.map = self.mapView;
             marker.userData = userId;
             [self setPictureForUserId:userId onMarker:marker];
        }
         
     } failure:^(NSError *error) {
         TALog(@"user location not found");
     }];
}

- (void)setPictureForUserId:(NSString *)userId
                   onMarker:(GMSMarker *)marker{

    if ([UIImage isImageAvailableInCacheForUserId:userId]) {
        UIImage *cachedImage = [UIImage cachedImageforUserId:userId];
        [self setPicture:cachedImage onMarker:marker];
    }else {
        if ([UIImage isAvailableLocallyForUserId:userId]) {
            
            NSString *imageFilePath = [UIImage filePathForUserId:userId];
            UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
            [self setPicture:image onMarker:marker];
            
            [UIImage updateImageForUserId:userId
                                  success:^(UIImage *image) {
                                      [self setPicture:image onMarker:marker];
                                  } failure:^(NSError *error) {
                                  }];
            
        }else{
            UIImage *defaultImage = [UIImage imageNamed:@"ico_user_25"];
            [self setPicture:defaultImage onMarker:marker];
            
            [UIImage
             downloadImageForUserId:userId
             success:^(UIImage *image) {
                 [self setPicture:image onMarker:marker];
             } failure:^(NSError *error) {
             }];
        }
    }
}

- (void)setPicture:(UIImage *)image
          onMarker:(GMSMarker *)marker{

    UIImage *backgroundImage = [UIImage imageNamed:@"ico_mappin_profilepic.png"];
    UIImage *fullImage = [UIImage mergeImagesWithTopImage:image bottomImage:backgroundImage];
    [marker setIcon:fullImage];
}

#pragma mark - Route Selection

- (void)showRouteSelectionFromSource:(Place *)source
                      andDestination:(Place *)destination{

    self.sourcePlace = source;
    self.destinationPlace = destination;
    
}

- (void)showRouteSelectionForRoutes:(NSArray *)routes
                             source:(Place *)source
                     andDestination:(Place *)destination{
    self.routes = routes;
    self.sourcePlace = source;
    self.destinationPlace = destination;
}

#pragma mark - fetch routes
- (void)fetchUserRouteForEvent:(Event *)event{

    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)
    [[UIApplication sharedApplication] delegate];
    
    if(event.routePoints == nil){
        if (appDelegate.netStatus != kNotReachable) {
            [self displayActivityIndicatorViewWithMessage:@"Loading route..."];
            
            [Event
             fetchRouteForEventId:event.eventId
             sucess:^(NSString *routePoints) {
                 event.routePoints = routePoints;
                 self.userRoute = [TARoute routeFromString:event.routePoints];
                 [self hideStatusMessage];
                 
             } failure:^(NSError *error) {
                 [self fetchRoutesAndDrawForMode:TAGoogleMapsOpenMode_showRoute];
             }];
        }else{
            [self displayNoInternetMessage];
        }
    }else{
        [self drawRoutes];
    }
}

- (void)fetchRoutesAndDrawForMode:(TAGoogleMapsOpenMode)mode{
    
    CLLocationCoordinate2D sourceCoordinate =
    CLLocationCoordinate2DMake(_sourcePlace.latitudeValue, _sourcePlace.longitudeValue);
    CLLocationCoordinate2D destinationCoordinate =
    CLLocationCoordinate2DMake(_destinationPlace.latitudeValue,_destinationPlace.longitudeValue);
    
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.netStatus != kNotReachable) {
        [self displayLoadingView];
        [[TAGoogleAPIManager sharedInstance]
         fetchRoutesFromCoordinate:sourceCoordinate
         toCoordinate:destinationCoordinate
         ifSucess:^(NSArray *routes) {
             
             if (mode == TAGoogleMapsOpenMode_routeSelection) {
                 self.routes = routes;
                 [self hideStatusMessage];
                 [self drawRoutes];
             }else{
                 [self hideStatusMessage];
                 [self drawPathForRoutePoints:[routes lastObject] withColor:kRouteColor_blue];
                 [self drawRoutes];
             }
             
         } ifFailure:^(NSError *error) {
             [self displayFailureMessage:@"Fetching routes failed."];
         }];
        
    }else{
        [self displayNoInternetMessage];
    }
}

#pragma mark - drawing methods

- (void)drawRoutes{

    if ([self isSourceAndDestinationSame] == YES) {
        [self displayFailureMessage:@"Source and destination locations shouldn't be same."];

        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.navigationController popViewControllerAnimated:YES];
        });
                
        return;
    }
    
    //Sketching the path with different colors
    int pathsCount = self.routes.count > 3 ? 3: self.routes.count;
    
    for (int i =0; i < pathsCount; i++) {
        id route = self.routes[i];
        [self drawPathForRoutePoints:route withColor:[self colorForIndex:i]];
    }
    
    if (pathsCount == 2) {
        [self.redButton setHidden:YES];
    }else if (pathsCount == 1){
        [self.redButton setHidden:YES];
        [self.greenButton setHidden:YES];
    }else if (pathsCount == 0){
        [self.blueButton setHidden:YES];
        [self.greenButton setHidden:YES];
        [self.redButton setHidden:YES];
    }

}

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

- (BOOL)isSourceAndDestinationSame{
    
    if (_sourcePlace.latitudeValue == _destinationPlace.latitudeValue &&
        _sourcePlace.longitudeValue == _destinationPlace.longitudeValue ) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - helper methods

- (void)removeRouteSelectionView{

    [_bottomBar removeFromSuperview];
    [_redButton removeFromSuperview];
    [_greenButton removeFromSuperview];
    [_blueButton removeFromSuperview];
}

- (UIColor *)colorForIndex:(int)i{

    UIColor *color = nil;
    switch (i%3) {
        case 0:
            color = kRouteColor_blue;
            break;
        case 1:
            color = kRouteColor_green;
            break;
        case 2:
            color = kRouteColor_red;
            break;
        default:
            break;
    }
    return color;
}

#pragma mark - action handlers

- (IBAction)routeSelectedWithButton:(id)sender{
    
    if([sender isKindOfClass:[UIButton class]]){
        UIButton *routeSelectionButton = (UIButton *)sender;
        int routeNumber = routeSelectionButton.tag;
        id routePoints = [self.routes objectAtIndex:routeNumber];

        CLLocationCoordinate2D sourceCoordinate =
        CLLocationCoordinate2DMake(self.sourcePlace.latitudeValue,
                                   self.sourcePlace.longitudeValue);

        CLLocationCoordinate2D destinationCoordinate =
        CLLocationCoordinate2DMake(self.destinationPlace.latitudeValue,
                                   self.destinationPlace.longitudeValue);
        
        TARoute *route = [TAGoogleAPIManager routeForRoutePoints:routePoints
                                            withSourceCoordinate:sourceCoordinate
                                           destinationCoordinate:destinationCoordinate
         ];

        if ([_delegate respondsToSelector:@selector(routeSelectedWithRoute:withIndex:)]) {
            [_delegate routeSelectedWithRoute:route withIndex:routeNumber+1];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
