//
//  TABaseViewController.h
//  goTogether
//
//  Created by Sunil Gandham on 24/01/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TABaseViewController : UIViewController

//- (void)setupBackButton;
- (void)displayNoResultsLabelWithMessage:(NSString *)message;

#pragma mark - displayActivityMessages
- (void)displayLoadingView;
- (void)displayNoInternetMessage;
- (void)displaySucessMessage:(NSString *)message;
- (void)displayFailureMessage:(NSString *)message;
- (void)displayActivityIndicatorViewWithMessage:(NSString *)messageString;
- (void)hideStatusMessage;
- (void)hideStatusMessageAfterDelay:(int)delay;

#pragma mark - NoResults
+ (UILabel *)noResultsLabel;
- (void)removeNoResultsLabel;

#pragma mark - PullToRefresh
- (void)setupPullToRefreshForTableView:(UITableView *)tableView;
- (void)stopRefreshing;
- (void)refresh:(id)sender;

#pragma mark - analytics
- (void)trackScreenName:(NSString *)screenName;

@end
