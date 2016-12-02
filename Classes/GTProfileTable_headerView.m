//
//  GTProfileTable_headerView.m
//  goTogether
//
//  Created by shirish on 08/07/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTProfileTable_headerView.h"
#import "UIImage+TAExtensions.h"
#import "User.h"
#import "GTUserStatsView.h"
#import "GTValidations.h"
#import "UIView+mm_ImageAdditions.h"
#import "UIImageView+GTExtensions.h"

#define kStarViewHeight 59.0f
#define kStarViewWidth 320.0f
#define kStarViewSizeFactor 0.3

@interface GTProfileTable_headerView()

@property (strong, nonatomic) User *user;
@property (strong, nonatomic) IBOutlet UIImageView *profilePic;
@end


@implementation GTProfileTable_headerView

- (void)setUserDetails:(User *)user {
    self.user = user;
    [self setProfilePicForUserId:user.userId];
}

- (void)setProfilePicForUserId:(NSString *)userId {
    
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
                 TALog(@"error: %@",error);
             }];
        }
    }
}

- (void)setPicture:(UIImage *)image {
    [self.profilePic setImage:image];
    [self.profilePic scaleProfilePic];
}

@end
