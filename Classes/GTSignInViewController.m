//
//  GTSignInViewController.m
//  goTogether
//
//  Created by shirish gone on 03/10/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTSignInViewController.h"
#import "TAFacebookManager.h"
#import "UIImage+TAExtensions.h"

@interface GTSignInViewController ()

- (IBAction)loginWithFacebookTouched:(id)sender;
- (IBAction)infoButtonTouched:(id)sender;

@end


@implementation GTSignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginWithFacebookTouched:(id)sender {
    //    [self displayActivityIndicatorViewWithMessage:@"Connecting to Facebook..."];
    [[TAFacebookManager sharedInstance] connectToFacebookWithHandleSuccess:^(id successMessage) {
        //        [self displaySucessMessage:@"Facebook connected!"];
    } andFailure:^(NSError *error) {
        //        [self displayFailureMessage:@"Failed to connect facebook"];
    }];
    
}



#pragma mark - Facebook Connection Notification Handlers

- (void)facebookConnected:(id)sender{
    
    NSNotification *notification = sender;
    if ([[notification name] isEqualToString:kNotificationType_facebookConnected])
    {
        NSDictionary* userInfo = [notification userInfo];
        TAFacebookUser *facebookUser= [userInfo objectForKey:kFacebookConnected_sendObject];
        TALog(@"Successfully received the test notification! %@", facebookUser);
        [UIImage
         startImageDownloadWithUrl:[TAFacebookManager pictureUrlForUserId:facebookUser.facebookID]
         success:^(UIImage *image) {
             //             [self setPicture:image];
         } failure:^(NSError *error) {
             //             [self displayFailureMessage:@"Picture download failed!"];
         }];
    }else{
        //        [self displayFailureMessage:@"Facebook connection failed."];
    }
}

- (void)facebookConnectFailed:(id)sender {
    [[GTAnalyticsManager sharedInstance] logFacebookConnectFailure];
}

@end
