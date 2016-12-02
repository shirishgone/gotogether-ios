//
//  GTPlacesManager.m
//  goTogether
//
//  Created by Shirish on 1/30/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTPlacesManager.h"

static GTPlacesManager *sharedInstance = nil;

@interface GTPlacesManager ()
@property (nonatomic, strong) NSManagedObjectContext *temporaryContext;

@end
@implementation GTPlacesManager

+(GTPlacesManager*)sharedInstance
{
    @synchronized([GTPlacesManager class])
    {
        if (!sharedInstance){
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
    return nil;
}

- (Place *)temporaryPlace{
    self.temporaryContext = [self temporaryContext];
    Place *place = [Place createInContext:self.temporaryContext];
    return place;
}
- (NSManagedObjectContext *)temporaryContext{
    if (_temporaryContext !=nil) {
        return _temporaryContext;
    }else{
        _temporaryContext = [NSManagedObjectContext contextWithParent:[NSManagedObjectContext defaultContext]];
        return _temporaryContext;
    }
}

- (void)cleanupTemporaryContext{
    [self.temporaryContext reset];
    self.temporaryContext = nil;
}
@end
