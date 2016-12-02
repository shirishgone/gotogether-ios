//
//  GTFriendFeedCell.m
//  goTogether
//
//  Created by Shirish on 2/9/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTRideDetailCell.h"
#import "UIImage+TAExtensions.h"
#import "UIImageView+GTExtensions.h"

@interface GTRideDetailCell ()
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *locationsLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateTimeLabel;
@property (nonatomic, strong) IBOutlet UIImageView *profilePictureView;
@property (nonatomic, strong) IBOutlet UIImageView *rideTypeImageView;
@end

@implementation GTRideDetailCell

- (void)setEvent:(Event *)event{
    _event = event;
    [_nameLabel setText:_event.userName];
    
    NSMutableString *sourceName = [NSMutableString stringWithString:_event.sourceName];
    [sourceName replaceOccurrencesOfString:@","
                                withString:@""
                                   options:NSCaseInsensitiveSearch
                                     range:NSMakeRange(0, [_event.sourceName length])
     ];
    
    NSMutableString *destinationName = [NSMutableString stringWithString:_event.destinationName];
    [destinationName replaceOccurrencesOfString:@","
                                     withString:@""
                                        options:NSCaseInsensitiveSearch
                                          range:NSMakeRange(0, [_event.destinationName length])
     ];
    
    
    NSString *travelString = [NSString stringWithFormat:@"%@ to %@", sourceName,destinationName];
    [_locationsLabel setText:travelString];
    
    NSString *timeString = [NSDate display_onlyTimeStringFromDate:_event.dateTime];
    NSString *dateString = [NSDate dateStringForEvent:_event];
    NSString *dayString = [NSDate display_dayOfTheWeekFromDate:_event.dateTime];
    [_dateTimeLabel setText:[NSString stringWithFormat:@"%@, %@, %@", timeString, dateString, dayString]];

    if ([_event.userType isEqualToString:@"owner"]) {
        [_rideTypeImageView setImage:[UIImage imageNamed:@"ico_car.png"]];
    }else{
        [_rideTypeImageView setImage:[UIImage imageNamed:@"ico_lift.png"]];
    }
    
    [self setProfilePictureForUserId:_event.userId];
}

#pragma mark - profile picture
- (void)setProfilePictureForUserId:(NSString *)userId{

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

@end
