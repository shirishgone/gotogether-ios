//
//  GTLaunchViewController.m
//  goTogether
//
//  Created by shirish on 01/12/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTLaunchViewController.h"
#import "UIImage+TAExtensions.h"
#import "UIView+Parallax.h"
#import "TAFacebookManager.h"
#import "GTAWSManager.h"
#import "GTPushNotificationManager.h"
#import "GTAboutViewController.h"

@interface GTLaunchViewController ()

@property (nonatomic, strong) IBOutlet UILabel *gotogetherTitleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, strong) UIImage *facebookProfilePicture;
- (IBAction)infoButtonTouched:(id)sender ;

@end

@implementation GTLaunchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self addParallaxToBackgroundImage];
    [self setTitleFont];
    [self addFacebookNotificationHadlers];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self trackScreenName:@"Launch"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [super viewWillDisappear:animated];
}

- (void)addParallaxToBackgroundImage {
    [self.backgroundImage addHorizantalParallaxEffectWithMinimumAndMaximumRelativeValue:25.0];
}

- (void)setTitleFont {
    UIFont *font = kFont_alba_Regular_45;
    [self.gotogetherTitleLabel setFont:font];
}

- (IBAction)infoButtonTouched:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier
                                                         bundle:[NSBundle mainBundle]];

    GTAboutViewController *aboutViewController =
    [storyBoard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_about];
    
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:aboutViewController];
    [aboutViewController showCancelButton];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - facebook methods

- (void)addFacebookNotificationHadlers {
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(facebookConnected:)
     name:kNotificationType_facebookConnected
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(facebookConnectFailed:)
     name:kNotificationType_facebookConnectFailed
     object:nil];
}

- (IBAction)facebookButtonTapped:(id)sender {
    [self displayLoadingView];
    [[TAFacebookManager sharedInstance] connectToFacebookWithHandleSuccess:^(id successMessage) {
    } andFailure:^(NSError *error) {
    }];
}

- (void)facebookConnected:(id)sender {
    NSNotification *notification = sender;
    if ([[notification name] isEqualToString:kNotificationType_facebookConnected])
    {
        NSDictionary* userInfo = [notification userInfo];
        TAFacebookUser *facebookUser= [userInfo objectForKey:kFacebookConnected_sendObject];
        if (facebookUser != nil) {
            [self loginWithFacebook:facebookUser];
        }
    }else{
        [self displayFailureMessage:@"Facebook connection failed."];
    }
}

- (void)facebookConnectFailed:(id)sender {
    
    NSNotification *notification = sender;
    if ([[notification name] isEqualToString:kNotificationType_facebookConnectFailed])
    {
        NSDictionary* userInfo = [notification userInfo];
        NSError *error = [userInfo objectForKey:kFacebookFailed_sendObject];

        [[GTAnalyticsManager sharedInstance] logFacebookConnectFailureWithError:error];
        [self displayFailureMessage:@"Facebook connect failed. Retry!"];
    }
}

- (void)loginWithFacebook:(TAFacebookUser *)facebookUser {

    User *user =  [User MR_createInContext:[NSManagedObjectContext defaultContext]];
    [user setFacebookId:facebookUser.facebookID];
    [user setUserId:facebookUser.emailId];
    [user setGender:facebookUser.gender];
    [user setName:facebookUser.fullName];
    [user setProfileDescription:facebookUser.profileDescription];
    [user setDateOfBirth:facebookUser.dateOfBirth];
    [user setFacebookProfileLink:facebookUser.profileUrl];
    
    // Register to Gotogether server
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.netStatus != kNotReachable) {
        [User
         loginWithFacebook:user
         facebookToken:facebookUser.facebookAccessToken
         sucess:^{

             [[NSNotificationCenter defaultCenter]
              postNotificationName:kNotificationType_loginSuccessful
              object:nil];

             [self dismissViewControllerAnimated:YES completion:nil];
         }failure:^(NSError *error) {
             NSString *errorDescription = [error.userInfo valueForKey:@"errorDescription"];
             if (errorDescription == nil) {
                 errorDescription = @"Something went wrong. Please try again!";
             }
             [self displayFailureMessage:errorDescription];
             TALog(@"error: %@",error);
         }];
        
    }else{
        [self displayNoInternetMessage];
    }
    [self hideStatusMessage];
}

@end
