//
//  TAGoogleMapsRouteViewController.h
//  goTogether
//
//  Created by shirish on 07/03/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@class TARoute;

typedef enum {
    GTMapMarker_normal,
    GTMapMarker_userLocation
} GTMapMarker;


typedef enum {
    TAGoogleMapsOpenMode_routeSelection,
    TAGoogleMapsOpenMode_showRoute
} TAGoogleMapsOpenMode;

@protocol TAGoogleMapsRouteSelectorDelegate <NSObject>
- (void)routeSelectedWithRoute:(TARoute *)route withIndex:(NSInteger)index;
@end

@interface GTGoogleMapsRouteViewController : TABaseViewController
@property (nonatomic, strong) IBOutlet GMSMapView *mapView;
@property (nonatomic, assign) id <TAGoogleMapsRouteSelectorDelegate> delegate;
@property (nonatomic, assign) TAGoogleMapsOpenMode mode;
@property (nonatomic, strong) Event *event;
@property (nonatomic, assign) BOOL isPresented;
@property (nonatomic, strong) NSArray *routes;

// Route Selection
- (void)showRouteSelectionFromSource:(Place *)source
                      andDestination:(Place *)destination;

- (void)showRouteSelectionForRoutes:(NSArray *)routes
                             source:(Place *)source
                     andDestination:(Place *)destination;
@end
