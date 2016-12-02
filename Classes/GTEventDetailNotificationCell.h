//
//  GTEventDetailNotificationCell.h
//  goTogether
//
//  Created by shirish on 21/05/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TANotification.h"
#import "Event.h"

@protocol GTEventDetailNotificationCellDelegate <NSObject>
- (void)acceptButtonTouchedForNotification:(TANotification *)notification;
- (void)rejectButtonTouchedForNotification:(TANotification *)notification;
@end

@interface GTEventDetailNotificationCell : UITableViewCell
@property (nonatomic, strong) TANotification *notification;
@property (nonatomic, assign) id <GTEventDetailNotificationCellDelegate> delegate;
@end
