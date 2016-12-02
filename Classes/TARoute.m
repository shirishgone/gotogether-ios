//
//  TARoute.m
//  goTogether
//
//  Created by shirish on 05/02/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "TARoute.h"
#import "TALocationManager.h"

@implementation TARoute

+ (NSString *)stringFromRoute:(TARoute *)route{
    NSMutableString *routePointsString = [[NSMutableString alloc] init];
    for (id routePoint in route.routePoints) {
        if ([routePoint isKindOfClass:[CLLocation class]]) {
            CLLocation *routePointLocation = routePoint;
            
            [routePointsString appendFormat:@"(%f,%f)",
             routePointLocation.coordinate.latitude,
             routePointLocation.coordinate.longitude];
            
            if ([[route.routePoints lastObject] isEqual:routePoint] == NO) {
                [routePointsString appendString:@","];
            }
        }
    }
    TALog(@"route Points String: %@",routePointsString);
    return routePointsString;
}

+ (TARoute *)routeFromString:(NSString *)string{
    NSMutableArray *routePoints = [[NSMutableArray alloc] init];
    
    NSArray *coordinatePoints = [string componentsSeparatedByString:@"),("];
    
    for (NSString *coordinateString  in coordinatePoints) {
        NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@"(,)"];
        NSArray *coordinateComponents = [[coordinateString stringByTrimmingCharactersInSet:characterSet] componentsSeparatedByString:@","];
        if ([coordinateComponents count] > 0) {
            NSString *longitude = [coordinateComponents lastObject];
            NSString *latitude = [coordinateComponents objectAtIndex:0];
            
            [routePoints addObject:[[CLLocation alloc] initWithLatitude:[latitude floatValue]
                                                              longitude:[longitude floatValue]]];
            
        }
    }
    TARoute *route = [[TARoute alloc] init];
    [route setRoutePoints:routePoints];
    return route;
}
@end
