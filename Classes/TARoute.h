//
//  TARoute.h
//  goTogether
//
//  Created by shirish on 05/02/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TARoute : NSObject
@property (nonatomic, strong) NSArray *routePoints;
@property (nonatomic, readwrite) double distance;
+ (NSString *)stringFromRoute:(TARoute *)route;
+ (TARoute *)routeFromString:(NSString *)string;
@end
