//
//  GTMapAnnotationViewController.m
//  goTogether
//
//  Created by shirish on 09/06/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTMapAnnotationViewController.h"
#import "Event.h"
#import "UIImage+TAExtensions.h"
#import "UIImageView+GTExtensions.h"

@interface GTMapAnnotationViewController()
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIImageView *profilePicture;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *destinationLocationLabel;
@property (nonatomic, weak) IBOutlet UIImageView *seatCountImageView;
@property (nonatomic, weak) IBOutlet UILabel *seatCountLabel;
@property (nonatomic, weak) IBOutlet UIImageView *rupeeImageView;
@property (nonatomic, weak) IBOutlet UILabel *seatPriceLabel;
@end

@implementation GTMapAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.userNameLabel setText:self.rideDetails.userName];
    [self.destinationLocationLabel setText:[NSString stringWithFormat:@"To %@",self.rideDetails.destinationName]];
    int seatCount = [self.rideDetails.availableSeats intValue];
    [self.seatCountLabel setText:[NSString stringWithFormat:@"%d",seatCount]];
    float seatPrice = self.rideDetails.seatPriceValue;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:0];
    NSString *costWithCurrencyCode = [numberFormatter stringFromNumber:
                                      [NSNumber numberWithFloat:seatPrice]];
    
    
    [self.seatPriceLabel setText:costWithCurrencyCode];
    [self setUserPicture];
}

- (void)setUserPicture {

    NSString *userId = self.rideDetails.userId;
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
            UIImage *defaultImage = [UIImage imageNamed:@"ico_profile_thumbnail_default.png"];
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

- (void)setPicture:(UIImage *)picture{
    
    [self.profilePicture setImage:picture];
    [self.profilePicture scaleProfilePic];
}
@end
