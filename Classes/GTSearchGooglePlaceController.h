//
//  TASeachLocationControllerViewController.h
//  goTogether
//
//  Created by shirish on 05/02/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  TASearchLocationControllerDelegate <NSObject>
- (void)selectedPlace:(Place *)place;
@end

@interface GTSearchGooglePlaceController : TABaseViewController
@property (nonatomic, assign) id <TASearchLocationControllerDelegate> delegate;
@end
