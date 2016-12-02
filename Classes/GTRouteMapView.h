//
//  GTRouteMapView.h
//  goTogether
//
//  Created by Shirish on 2/11/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GTRouteMapView : UIView

@property (nonatomic, strong) NSArray *routePoints;

- (void)setSourceCoordinate:(CLLocationCoordinate2D)source
andDestinationCoordinate:(CLLocationCoordinate2D)destination;

@end
