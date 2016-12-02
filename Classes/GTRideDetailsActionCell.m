//
//  GTRideDetailsActionCell.m
//  goTogether
//
//  Created by shirish on 30/06/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTRideDetailsActionCell.h"

@interface GTRideDetailsActionCell ()
@property (nonatomic, weak) IBOutlet UIButton *rideRequestButton;
- (IBAction)requestButtonTouched:(id)sender;
@end

@implementation GTRideDetailsActionCell

- (void)awakeFromNib {

    [self.contentView setBackgroundColor:[UIColor clearColor]];
}

- (IBAction)requestButtonTouched:(id)sender{
    if (_delegate !=nil && [_delegate respondsToSelector:@selector(requestRideTouched)]) {
        [_delegate requestRideTouched];
    }
}

- (void)setupRideButton{

    UIImage *image_blue_normal = [UIImage imageNamed:@"askaridebutton.png"];
    UIImage *image_blue_pressed = [UIImage imageNamed:@"askaridebutton.png"];
    
    UIImage *image_orange_normal = [UIImage imageNamed:@"btn_orange_normal"];
    UIImage *image_orange_pressed = [UIImage imageNamed:@"btn_orange_normal"];
    
    if ([self isInRequestedUsersList]) {
        
        [self.rideRequestButton setBackgroundImage:image_blue_normal
                                          forState:UIControlStateNormal];
        [self.rideRequestButton setBackgroundImage:image_blue_pressed
                                          forState:UIControlStateHighlighted];
        [self.rideRequestButton setTitle:@"Request Sent!"
                                forState:UIControlStateNormal];
        [self.rideRequestButton setUserInteractionEnabled:NO];
        
    }else if ([_eventDetails userTypeValue] == userType_driving
              && _eventDetails.availableSeatsValue > 0) {
        
        [self.rideRequestButton setBackgroundImage:image_orange_normal
                                          forState:UIControlStateNormal];
        [self.rideRequestButton setBackgroundImage:image_orange_pressed
                                          forState:UIControlStateHighlighted];
        
        [self.rideRequestButton setTitle:@"Request a Ride!"
                                forState:UIControlStateNormal];
        [self.rideRequestButton setUserInteractionEnabled:YES];

        
    }else if([_eventDetails userTypeValue] == userType_passenger){
        
        [self.rideRequestButton setBackgroundImage:image_blue_normal
                                          forState:UIControlStateNormal];
        
        [self.rideRequestButton setBackgroundImage:image_blue_pressed
                                          forState:UIControlStateHighlighted];
        
        [self.rideRequestButton setTitle:@"Offer a Ride!"
                                forState:UIControlStateNormal];
        [self.rideRequestButton setUserInteractionEnabled:YES];
    }
}

- (BOOL)isInRequestedUsersList {
    User *currentUser = [User currentUser];
    NSArray *requestedUsers = _eventDetails.requestedUsers;
    for (NSString *requested_userId in requestedUsers) {
        if([currentUser.userId isEqualToString:requested_userId]){
            return YES;
        }
    }
    return NO;
}

- (void)setEventDetails:(Event *)eventDetails{
    _eventDetails = eventDetails;
    [self setupRideButton];
}

@end
