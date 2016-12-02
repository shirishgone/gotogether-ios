//
//  TABaseViewController.m
//  goTogether
//
//  Created by Sunil Gandham on 24/01/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "TABaseViewController.h"
#import "Reachability.h"
#import "goTogetherAppDelegate.h"
#import "SVProgressHUD.h"
#import "TAFacebookManager.h"
#import "GTTwitterManager.h"
#import "GTDataManager.h"
#import <Parse/Parse.h>

#define kNoResultsLabelTag  30

//static const float kIndicatorTimeOut = 5.0f;
//static const float kAnimationDuration = 0.65;
//static const float kIndicatorTimeOut_Max = 10.0f;

@interface TABaseViewController ()
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation TABaseViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.view setBackgroundColor:kColorGlobalBackground];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(networkChangeNotification:)
     name:kReachabilityNotification
     object:nil];
    
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)
    [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.netStatus == kNotReachable) {
        [self displayNoInternetMessage];
    }
}

- (void)viewDidUnload {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (void)networkChangeNotification:(NSNotification *)note {
    
    goTogetherAppDelegate *appdelegate = [note object];
    Reachability *networkReachability = [appdelegate networkReachability];
    NetworkStatus netStatus = [networkReachability currentReachabilityStatus];
    switch (netStatus)
    {
        case ReachableViaWWAN: {
            break;
        }
        case ReachableViaWiFi: {
            break;
        }
        case NotReachable: {
            [self displayNoInternetMessage];
        }
    }
}

#pragma mark - shake detection

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:kReachabilityNotification
     object:nil];
    [super viewWillDisappear:animated];
}

#pragma mark - Refresh control
- (void)setupPullToRefreshForTableView:(UITableView *)tableView{
    
    // Set up the UIRefreshControl.
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refresh:)
                  forControlEvents:UIControlEventValueChanged];
    
    // Create a UITableViewController so we can use a UIRefreshControl.
    UITableViewController *tvc = [[UITableViewController alloc] initWithStyle:tableView.style];
    tvc.tableView = tableView;
    tvc.refreshControl = self.refreshControl;
    [self addChildViewController:tvc];
}

- (void)refresh:(id)sender{
    // OverRide in subclass
}

- (void)stopRefreshing {
    [self.refreshControl endRefreshing];
}

#pragma mark - StatusIndicators

+ (UILabel *)noResultsLabel {
    UILabel *matchesLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 160.0, 260.0, 80.0)];
    matchesLabel.font = kFont_HelveticaNeueRegular_14;
    matchesLabel.tag = kNoResultsLabelTag;
    matchesLabel.textColor = kColorPalette_darkGreen;
    matchesLabel.minimumScaleFactor = 1.5;
    matchesLabel.numberOfLines = 3;
    matchesLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    matchesLabel.shadowColor = [UIColor whiteColor];
    matchesLabel.shadowOffset = CGSizeMake(0, 1);
    matchesLabel.backgroundColor = [UIColor clearColor];
    matchesLabel.textAlignment =  NSTextAlignmentCenter;
    return matchesLabel;
}

- (void)displayNoResultsLabelWithMessage:(NSString *)message {
    
    [self removeNoResultsLabel];
    UILabel *matchesLabel = [TABaseViewController noResultsLabel];
    [matchesLabel setText:message];
    [self.view addSubview:matchesLabel];
}

- (void)removeNoResultsLabel {
    UILabel *label = (UILabel *)[self.view viewWithTag:kNoResultsLabelTag];
    [label removeFromSuperview];
}

#pragma mark - Loading Indicator
- (void)displayLoadingView {
    [SVProgressHUD show];
}

- (void)displayNoInternetMessage {
    [SVProgressHUD showErrorWithStatus:@"No Internet Connection"];
}

- (void)displaySucessMessage:(NSString *)message {
    [SVProgressHUD showSuccessWithStatus:message];
}

- (void)displayFailureMessage:(NSString *)message {
    [SVProgressHUD showErrorWithStatus:message];
}

- (void)displayActivityIndicatorViewWithMessage:(NSString *)messageString {
    [SVProgressHUD showWithStatus:messageString];
}

- (void)hideStatusMessage {
    double delayInSeconds = 2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [SVProgressHUD dismiss];
    });
}

- (void)hideStatusMessageAfterDelay:(int)delay {
    
    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [SVProgressHUD dismiss];
    });
}


#pragma mark - Analytics

- (void)trackScreenName:(NSString *)screenName {
    [PFAnalytics trackEvent:@"TrackScreenViews"
                 dimensions:@{ @"screenName": screenName }];
}


@end
