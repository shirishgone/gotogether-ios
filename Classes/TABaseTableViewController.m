//
//  TABaseTableViewController.m
//  goTogether
//
//  Created by shirish on 03/04/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "TABaseTableViewController.h"
#import "Reachability.h"
#import "goTogetherAppDelegate.h"
#import "SVProgressHUD.h"
#import <MapKit/MKMapView.h>
#import "TALocationManager.h"
#import "UIView+mm_ImageAdditions.h"
#import "UIImage+GTBlurring.h"
#import "TAFacebookManager.h"
#import "GTTwitterManager.h"
#import "GTDataManager.h"
#import <Parse/Parse.h>

#define kNoResultsLabelTag  30

@interface TABaseTableViewController () <MKMapViewDelegate>

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation TABaseTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.view setBackgroundColor:kColorGlobalBackground];
    self.appDelegate = (goTogetherAppDelegate*)
    [[UIApplication sharedApplication]delegate];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(networkChangeNotification:)
     name:kReachabilityNotification
     object:nil];
    
    if (self.appDelegate.netStatus == kNotReachable) {
        [self displayNoInternetMessage];
    }
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
- (void)setupPullToRefresh {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:self.refreshControl];
}

- (void)refresh:(id)sender {
    // OverRide in subclass
}

- (void)stopRefreshing {
    [self.refreshControl endRefreshing];
}

#pragma mark - StatusIndicators

- (void)displayNoResultsLabelWithMessage:(NSString *)message {
    
    [self removeNoResultsLabel];
    UILabel *matchesLabel = [TABaseViewController noResultsLabel];
    [matchesLabel setText:message];
    [self.view addSubview:matchesLabel];
}

- (void)removeNoResultsLabel{
    UILabel *label = (UILabel *)[self.view viewWithTag:kNoResultsLabelTag];
    [label removeFromSuperview];
}

#pragma mark - Loading Indicator

- (void)displayLoadingView{
    
    [SVProgressHUD show];
}

- (void)displayNoInternetMessage {
    
    [SVProgressHUD showErrorWithStatus:@"No Internet Connection"];
}

- (void)displaySucessMessage:(NSString *)message{
    
    [SVProgressHUD showSuccessWithStatus:message];
}

- (void)displayFailureMessage:(NSString *)message{
    
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


#pragma mark - Analytics

- (void)trackScreenName:(NSString *)screenName {
    
    [PFAnalytics trackEvent:@"TrackScreenViews"
                 dimensions:@{ @"screenName": screenName }];
}

@end
