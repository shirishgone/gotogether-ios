//
//  GTAddAdvancedViewController.h
//  goTogether
//
//  Created by shirish on 13/08/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GTAddRequestMoreDelegate <NSObject>

- (void)selectedSeatCount:(int)seatCount
                    price:(double)price
                    route:(TARoute *)route
            taggedFriends:(NSArray *)taggedFriends;

@end

@interface GTAddAdvancedViewController : TABaseTableViewController
@property (nonatomic) GTUserType *userTypeSelected;
@property (nonatomic, assign) id <GTAddRequestMoreDelegate> delegate;
@property (nonatomic, readwrite) CLLocationCoordinate2D sourceCoordinate;
@property (nonatomic, readwrite) CLLocationCoordinate2D destinationCoordinate;
@property (nonatomic, strong) NSString *sourceName;
@property (nonatomic, strong) NSString *destinationName;
@property (nonatomic, readwrite) float seatPrice;
@property (nonatomic, strong) NSArray *fetchedRoutes;

- (void)setSelectedSeatCount:(int)count
                   seatPrice:(float)seatPrice
                 withFriends:(NSArray *)friends;
@end
