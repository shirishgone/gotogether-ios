//
//  GTPlacesManager.h
//  goTogether
//
//  Created by Shirish on 1/30/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Place.h"

@interface GTPlacesManager : NSObject
- (Place *)temporaryPlace;
+(GTPlacesManager*)sharedInstance;

- (NSManagedObjectContext *)temporaryContext;
- (void)cleanupTemporaryContext;
@end
