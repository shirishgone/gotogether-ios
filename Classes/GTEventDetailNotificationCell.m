//
//  GTEventDetailNotificationCell.m
//  goTogether
//
//  Created by shirish on 21/05/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "GTEventDetailNotificationCell.h"
#import "UIImage+TAExtensions.h"

@interface GTEventDetailNotificationCell()

@property (nonatomic, strong) IBOutlet UIImageView *profilePictureView;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UIButton *acceptButton;
@property (nonatomic, strong) IBOutlet UIButton *rejectButton;
- (IBAction)acceptButtonTouched:(id)sender;
- (IBAction)rejectButtonTouched:(id)sender;
@end
@implementation GTEventDetailNotificationCell

- (void)setNotification:(TANotification *)notification{
    _notification = notification;

    NSString *messageString = nil;
    if (notification.notificationType == TANotificationType_bookSeat) {
         messageString = [NSString stringWithFormat:@"%@ has requested for a ride.",notification.userName];
        
    }else if (notification.notificationType == TANotificationType_pickupRequest){
         messageString = [NSString stringWithFormat:@"%@ wants to pick you.",notification.userName];
    }
    [self.messageLabel setText:messageString];
    [self showUserPictureForUserId:notification.userId];
}

- (void)showUserPictureForUserId:(NSString *)userId{
    if ([UIImage isAvailableLocallyForUserId:userId]) {
        
        NSString *imageFilePath = [UIImage filePathForUserId:userId];
        UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
        [self setPicture:image];
        
    }else{
        UIImage *defaultImage = [UIImage imageNamed:@"ico_profile_thumbnail_default.png"];
        [self setPicture:defaultImage];
        
        [UIImage
         getImageForId:userId
         success:^(UIImage *image) {
             [self setPicture:image];
         } failure:^(NSError *error) {
         }];
    }
}

- (void)setPicture:(UIImage *)image{
    
    [_profilePictureView setImage:image];
    [_profilePictureView.layer setCornerRadius:self.profilePictureView.frame.size.width / 2.0];
    [_profilePictureView.layer setMasksToBounds:YES];
    [_profilePictureView.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [_profilePictureView.layer setBorderWidth:0.5];
    [self layoutSubviews];
}

#pragma mark - action handlers
- (IBAction)acceptButtonTouched:(id)sender{
    
    if ([_delegate respondsToSelector:@selector(acceptButtonTouchedForNotification:)]) {
        [_delegate acceptButtonTouchedForNotification:self.notification];
    }
}

- (IBAction)rejectButtonTouched:(id)sender{
    if ([_delegate respondsToSelector:@selector(rejectButtonTouchedForNotification:)]) {
        [_delegate rejectButtonTouchedForNotification:self.notification];
    }
}

@end
