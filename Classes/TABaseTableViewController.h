//
//  TABaseTableViewController.h
//  goTogether
//
//  Created by shirish on 03/04/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "goTogetherAppDelegate.h"

@interface TABaseTableViewController : UITableViewController
@property (nonatomic, strong) goTogetherAppDelegate *appDelegate;

- (void)displayNoResultsLabelWithMessage:(NSString *)message;

#pragma mark - displayActivityMessages
- (void)displayLoadingView;
- (void)displayNoInternetMessage;
- (void)displaySucessMessage:(NSString *)message;
- (void)displayFailureMessage:(NSString *)message;
- (void)displayActivityIndicatorViewWithMessage:(NSString *)messageString;
- (void)hideStatusMessage;

#pragma mark - NoResults
- (void)removeNoResultsLabel;

#pragma mark - PullToRefresh
- (void)stopRefreshing;
- (void)setupPullToRefresh;
- (void)refresh:(id)sender;

#pragma mark - analytics
- (void)trackScreenName:(NSString *)screenName;

@end
