//
//  GTNotificationTableViewCell.h
//  goTogether
//
//  Created by shirish gone on 04/04/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GTNotificationTableViewCell : UITableViewCell

@property (nonatomic, strong) Notification *notification;

- (void)setReadMode:(BOOL)read;

@end
