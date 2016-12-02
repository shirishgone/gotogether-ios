//
//  GTCoTravellersAndCostCell.m
//  goTogether
//
//  Created by shirish on 23/04/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTEventDetailsTravellersCell.h"
#import "UIImage+TAExtensions.h"
#import "Event.h"
#import "UIImageView+GTExtensions.h"

@interface GTEventDetailsTravellersCell()

@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, strong) IBOutlet UIButton *callButton;

@end


@implementation GTEventDetailsTravellersCell

- (void)setTravellerDetail:(GTTravellerDetails *)travellerDetail {
    _travellerDetail = travellerDetail;

    [self setPictureForUserId:_travellerDetail.userId];
    [self setUserName:_travellerDetail.name];
}

- (void)setCanShowCallButton:(BOOL)canShowCallButton {
    _canShowCallButton = canShowCallButton;
    [self.callButton setHidden:!canShowCallButton];
}

- (void)setUserName:(NSString *)userName{
    [self.userNameLabel setText:userName];
}

- (void)setPictureForUserId:(NSString *)userId{
    
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

- (void)setPicture:(UIImage *)image {
    [_userImageView setImage:image];
    [_userImageView scaleProfilePic];
}

- (IBAction)callButtonTouched:(id)sender {
    NSString *phoneNumberString = self.travellerDetail.phoneNumber;
    if (phoneNumberString != nil) {
        NSString *totalString = [@"telprompt://" stringByAppendingString:phoneNumberString];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:totalString]];
    }
}

@end
