//
//  GTEventDetailsHeaderView.m
//  goTogether
//
//  Created by Pavan Krishna on 19/04/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTEventDetailsHeaderView.h"
#import "GTRouteMapView.h"
#import "UIImage+TAExtensions.h"
#import "UIImageView+GTExtensions.h"

@interface GTEventDetailsHeaderView()

@property(nonatomic, weak) IBOutlet UIImageView *profilePictureView;
@property(nonatomic, weak) IBOutlet UILabel *userName;
@property(nonatomic, weak) IBOutlet UILabel *timeLabel;
@property(nonatomic, weak) IBOutlet UILabel *seatCostLabel;
@property(nonatomic, weak) IBOutlet UILabel *seatCountLabel;
@property(nonatomic, weak) IBOutlet UILabel *vehicleLabel;

@end

@implementation GTEventDetailsHeaderView

- (void)setEventInfo:(Event *)event {
    _eventInfo = event;

    [self setProfilePictureForUserId:event.userId];
    [self.userName setText:event.userName];
    [self setVehicleDetails:event.vehicle];

    [self setDate:event.dateTime];
    [self setPrice:event.seatPriceValue];
    [self setSeatCount:[event.availableSeats integerValue]];
}

- (void)setVehicleDetails:(Vehicle *)vehicle {

    NSString *vehicleString = nil;
    if (vehicle!=nil) {
        vehicleString = [NSString stringWithFormat:@"%@ %@",vehicle.make, vehicle.model];
    }else{
        vehicleString = @"";
    }
    self.vehicleLabel.text = vehicleString;
}

- (void)setDate:(NSDate *)date {

    NSMutableString *dateTimeString = [[NSMutableString alloc] init];
    if ([NSDate isToday:date]) {
        [dateTimeString appendString:@"Today"];
    }else{
        [dateTimeString appendString:[NSDate display_onlyDateStringFromDate:date]];
        [dateTimeString appendString:@", "];
        [dateTimeString appendString:[NSDate display_dayOfTheWeekFromDate:date]];
    }
    [dateTimeString appendString:@", "];
    [dateTimeString appendString:[NSDate display_onlyTimeStringFromDate:_eventInfo.dateTime]];
    [self.timeLabel setText:dateTimeString];
}

- (void)setPrice:(double)price {
    if (price > 0.0) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        NSString *costWithCurrencyCode = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:price]];
        
        NSString *seatCostString = [NSString stringWithFormat:@"%@ per seat",costWithCurrencyCode];
        [_seatCostLabel setText:seatCostString];
    }else{
        [_seatCostLabel setText:@"Free Ride"];
    }
}

- (void)setSeatCount:(NSInteger)seatCount {
    NSString *seatsString;
    if (seatCount == 1) {
        seatsString = @"1 Seat";
    }else{
        seatsString = [NSString stringWithFormat:@"%d seats",seatCount];
    }
    [_seatCountLabel setText:seatsString];
}

- (void)setPicture:(UIImage *)image {
    [_profilePictureView setImage:image];
    [_profilePictureView scaleProfilePic];
}

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
            UIImage *defaultImage = [UIImage imageNamed:@"ico_user_40.png"];
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

@end
