//
//  GTCreateRideTableCell_SeatCountAndCost.h
//  goTogether
//
//  Created by shirish on 09/04/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GTTableCell_CreateRide_SeatCountAndCost_Delegate <NSObject>
- (void)keyboardShown;
- (void)keyboardHidden;

- (void)priceSelected:(double)price;
- (void)numberOfSeatsSelected:(NSInteger)seatsCount;
@end

@interface GTTableCell_CreateRide_SeatCountAndCost : UITableViewCell
@property (nonatomic, assign) id <GTTableCell_CreateRide_SeatCountAndCost_Delegate> delegate;
@property (nonatomic) NSInteger seatCount;
@property (nonatomic) double cost;
@end
