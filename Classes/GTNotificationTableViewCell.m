//
//  GTNotificationTableViewCell.m
//  goTogether
//
//  Created by shirish gone on 04/04/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTNotificationTableViewCell.h"
#import "GTNotificationTableViewCell_Protected.h"
#import "UIImage+TAExtensions.h"
#import "UIImageView+GTExtensions.h"

@implementation GTNotificationTableViewCell

- (void)setNotification:(Notification *)notification{
    _notification = notification;
    [self setReadMode:notification.readValue];
    [self setProfilePictureForUserId:notification.userId];
    [self.notificationTextLabel setText:notification.alertMessage];
    
}

- (void)setReadMode:(BOOL)read{
    if (read == YES) {
        self.notificationTextLabel.alpha = 0.5;
        self.profilePicture.alpha = 0.5;
        self.backgroundView.alpha = 0.5;
    }else{
        self.notificationTextLabel.alpha = 1.0;
        self.profilePicture.alpha = 1.0;
        self.backgroundView.alpha = 1.0;
    }
}
#pragma mark - profile picture
- (void)setProfilePictureForUserId:(NSString *)userId {
    if ([UIImage isImageAvailableInCacheForUserId:userId]) {
        UIImage *cachedImage = [UIImage cachedImageforUserId:userId];
        [self setPicture:cachedImage];
    }else {
        if ([UIImage isAvailableLocallyForUserId:userId]) {
            
            NSString *imageFilePath = [UIImage filePathForUserId:userId];
            UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
            [self setPicture:image];
            
            [UIImage updateImageForUserId:userId
                                  success:^(UIImage *image) {
                                      [self setPicture:image];
                                  } failure:^(NSError *error) {
                                  }];
            
        }else{
            UIImage *defaultImage = [UIImage imageNamed:@"ico_user_40"];
            [self setPicture:defaultImage];
            
            [UIImage
             downloadImageForUserId:userId
             success:^(UIImage *image) {
                 [self setPicture:image];
             } failure:^(NSError *error) {
             }];
        }
    }
}

- (void)setPicture:(UIImage *)image{
    
    [self.profilePicture setImage:image];
    [self.profilePicture scaleProfilePic];
}

@end
