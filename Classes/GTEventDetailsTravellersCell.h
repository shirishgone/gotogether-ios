//
//  GTCoTravellersAndCostCell.h
//  goTogether
//
//  Created by shirish on 23/04/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface GTEventDetailsTravellersCell : UITableViewCell

@property (nonatomic, strong) GTTravellerDetails *travellerDetail;
@property (nonatomic, readwrite) BOOL canShowCallButton;

@end
