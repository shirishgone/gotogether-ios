//
//  GTEventDetailNotificationCell.m
//  goTogether
//
//  Created by shirish on 21/05/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTEventDetail_RideRequestCell.h"
#import "UIImage+TAExtensions.h"
#import "SIAlertView.h"
#import "UIImageView+GTExtensions.h"

@interface GTEventDetail_RideRequestCell()

@property (nonatomic, strong) IBOutlet UIImageView *profilePictureView;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;

@property (nonatomic, strong) IBOutlet UIButton *acceptButton;
@property (nonatomic, strong) IBOutlet UIButton *viewProfileButton;

@property (nonatomic, strong) User *requestedUser;
- (IBAction)acceptButtonTouched:(id)sender;
- (IBAction)viewProfileButtonTouched:(id)sender;
@end

@implementation GTEventDetail_RideRequestCell

- (void)awakeFromNib {
    [self setCornerRadiusForButtons];
}

- (void)setCornerRadiusForButtons {
    _acceptButton.layer.cornerRadius = 5.0;
    _acceptButton.clipsToBounds = YES;
    
    _viewProfileButton.layer.cornerRadius = 5.0;
    _viewProfileButton.clipsToBounds = YES;
}

- (void)setRequestedUserDetail:(GTTravellerDetails *)requestedUserDetail {
    _requestedUserDetail = requestedUserDetail;
    
    [self showRequestStringForUserName:_requestedUserDetail.name];
    [self setProfilePictureForUserId:_requestedUserDetail.userId];
    
}

#pragma mark - user name methods

- (void)showRequestStringForUserName:(NSString *)userName {
    NSString *messageString = [NSString stringWithFormat:@"%@ has requested for a ride.",userName];
    [self.messageLabel setText:messageString];
}

#pragma mark - profile picture methods

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
    
    [_profilePictureView setImage:image];
    [_profilePictureView scaleProfilePic];
}

#pragma mark - action handlers

- (IBAction)acceptButtonTouched:(id)sender {
    if ([_delegate respondsToSelector:@selector(acceptButtonTouchedForRequestedUserId:)]) {
        [_delegate acceptButtonTouchedForRequestedUserId:self.requestedUserDetail.userId];
    }
}

- (IBAction)viewProfileButtonTouched:(id)sender{
    if ([_delegate respondsToSelector:@selector(viewProfileButtonTouchedWithUsedId:)]) {
        [_delegate viewProfileButtonTouchedWithUsedId:self.requestedUserDetail.userId];
    }
}

@end
