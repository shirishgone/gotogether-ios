//
//  GTSearchResultTableCell.m
//  goTogether
//
//  Created by shirish on 03/04/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTSearchResultTableCell.h"
#import "UIImage+TAExtensions.h"
#import "TALocationManager.h"
#import "UIImageView+GTExtensions.h"

@interface GTSearchResultTableCell()

@property (nonatomic, weak) IBOutlet UIImageView *profilePictureView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *fromLocationLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
//@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, strong) IBOutlet UIImageView *rideTypeImageView;


@end

@implementation GTSearchResultTableCell

- (void)setEventDetails:(Event *)eventDetails {

    NSString *fromToLocationString = [NSString stringWithFormat:@"%@ to %@",
                                      eventDetails.sourceName,
                                      eventDetails.destinationName];
    
    [self.fromLocationLabel setText:fromToLocationString];
    [self.nameLabel setText:eventDetails.userName];
    [self setProfilePictureForUserId:eventDetails.userId];
    
    // Set Date
    NSString *timeString = [NSDate display_onlyTimeStringFromDate:eventDetails.dateTime];
    NSString *dateString = [NSDate dateStringForEvent:eventDetails];
    NSString *dayString = [NSDate display_dayOfTheWeekFromDate:eventDetails.dateTime];
    [_dateLabel setText:[NSString stringWithFormat:@"%@, %@, %@", timeString, dateString, dayString]];
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

- (void)setPicture:(UIImage *)image {
    [_profilePictureView setImage:image];
    [_profilePictureView scaleProfilePic];
}

@end
