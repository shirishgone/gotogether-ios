//
//  GTMyRideCell.m
//  goTogether
//
//  Created by shirish on 02/08/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTMyRideCell.h"

@interface GTMyRideCell ()
@property (nonatomic, weak) IBOutlet UIImageView *travelType_imageView;
@property (nonatomic, weak) IBOutlet UILabel *fromLocationLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *notificationsBackgroundImageView;
@property (nonatomic, weak) IBOutlet UILabel *notificationsCountLabel;


@end
@implementation GTMyRideCell

- (void)setEvent:(Event *)event{

    _event = event;
    
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
    NSString *timeString = [NSDate display_onlyTimeStringFromDate:_event.dateTime];
    NSString *dateString = [NSDate dateStringForEvent:_event];
    [_timeLabel setText:[NSString stringWithFormat:@"%@ %@", timeString, dateString]];
        
    if ([_event.userType isEqualToString:@"owner"]) {
        [_travelType_imageView setImage:[UIImage imageNamed:@"ico_car.png"]];
    }else{
        [_travelType_imageView setImage:[UIImage imageNamed:@"ico_lift.png"]];
    }
    
    if ([_event canShowNotifications]) {
        // Ride Requests Notifications Count Label
        NSArray *rideRequests = [self.event rideRequests];
        [self.notificationsCountLabel setText:[NSString stringWithFormat:@"%d",[rideRequests count]]];

    }else{
        [self.notificationsBackgroundImageView removeFromSuperview];
        [self.notificationsCountLabel removeFromSuperview];
    }
}

@end

