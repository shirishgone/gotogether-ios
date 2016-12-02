//
//  TACoTravellerViewController.h
//  TravelApp
//
//  Created by shirish on 23/11/12.
//  Copyright (c) 2012 mutualmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GTSearchObject : NSObject
@property (nonatomic, strong) Place *sourcePlace;
@property (nonatomic, strong) Place *destinationPlace;
@property (nonatomic, strong) NSDate *date;
@end

@interface GTSearchEntryViewController : TABaseTableViewController
@end
