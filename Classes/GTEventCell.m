//
//  GTImPassengerCell.m
//  goTogether
//
//  Created by shirish on 18/04/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "GTEventCell.h"
#import "UIImage+TAExtensions.h"
#import "UIImageView+GTExtensions.h"

@interface GTEventCell()
@property (nonatomic, weak) IBOutlet UIImageView *profilePictureView;
@property (nonatomic, weak) IBOutlet UIImageView *travelType_imageView;
@property (nonatomic, weak) IBOutlet UILabel *fromLocationLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *dayLabel;

@property (nonatomic, weak) IBOutlet UIImageView *notificationsBackgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel *notificationsCountLabel;
@end

@implementation GTEventCell

- (void)setCellType:(GTEventCellType)type{
    _cellType = type;
    

    if (type == GTEventCellType_searchResult) {
        [self showTravelTypeImage:NO];
    }
}

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
    [_fromLocationLabel setText:travelString];
    [_timeLabel setText:[NSDate display_onlyTimeStringFromDate:_event.dateTime]];

    if ([NSDate isToday:_event.dateTime]) {
        [_dateLabel setText:@"Today"];
        [_dayLabel setText:@""];
    }else{
        [_dateLabel setText:[NSDate display_onlyDateStringFromDate:_event.dateTime]];
        [_dayLabel setText:[NSDate display_dayOfTheWeekFromDate:_event.dateTime]];
    }

    if ([_event.userType isEqualToString:@"owner"]) {
        [_travelType_imageView setImage:[UIImage imageNamed:@"ico_car.png"]];
    }else{
        [_travelType_imageView setImage:[UIImage imageNamed:@"ico_lift.png"]];
    }
    
    [self setProfilePictureForUserId:_event.userId];
    
    
    if ([_event canShowNotifications]) {
        // Ride Requests Notifications Count Label
        NSArray *rideRequests = [self.event rideRequests];
        [self.notificationsCountLabel setText:[NSString stringWithFormat:@"%d",[rideRequests count]]];
        
    }else{
        [self.notificationsBackgroundImageView removeFromSuperview];
        [self.notificationsCountLabel removeFromSuperview];
    }
}
#pragma mark - car or passenger image
- (void)showTravelTypeImage:(BOOL)show{
    if (show == NO) {
        [self.travelType_imageView setHidden:YES];
    }else{
        [self.travelType_imageView setHidden:NO];
    }
}

#pragma mark - profile picture
- (void)setProfilePictureForUserId:(NSString *)userId{
    if ([UIImage isAvailableLocallyForUserId:userId]) {
        
        NSString *imageFilePath = [UIImage filePathForUserId:userId];
        UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
        [self setPicture:image];
        
    }else{
        UIImage *defaultImage = [UIImage imageNamed:@"ico_user_40"];
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
    [_profilePictureView scaleProfilePic];
}

@end
