//
//  GTVerifications.h
//  goTogether
//
//  Created by shirish on 16/03/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vehicle.h"

@interface GTVerifications : NSObject
+ (void)verifyVehicle:(Vehicle *)vehicle
               sucess:(void (^)(BOOL verified))handleSuccess
              failure:(void (^)(NSError *error))handleFailure;
@end
