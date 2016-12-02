//
//  GTEventDetailNotificationCell.h
//  goTogether
//
//  Created by shirish on 21/05/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@protocol GTEventDetail_RideRequestCell_delegate <NSObject>
- (void)acceptButtonTouchedForRequestedUserId:(NSString *)userId;
- (void)viewProfileButtonTouchedWithUsedId:(NSString *)userId;
@end

@interface GTEventDetail_RideRequestCell : UITableViewCell

@property (nonatomic, strong) GTTravellerDetails *requestedUserDetail;
@property (nonatomic, assign) GTUserType event_createdUserType;
@property (nonatomic, assign) id <GTEventDetail_RideRequestCell_delegate> delegate;

@end
