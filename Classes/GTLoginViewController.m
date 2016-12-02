//
//  GTLoginViewController.m
//  goTogether
//
//  Created by shirish on 19/03/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "GTLoginViewController.h"
#import "GTValidations.h"
#import "User.h"
#import "NSManagedObject+MagicalRecord.h"
#import "goTogetherAppDelegate.h"
#import "TAFacebookManager.h"
#import "GTPushNotificationManager.h"

@interface GTLoginViewController () <UITextFieldDelegate>
@property (nonatomic, strong) IBOutlet UITextField *emailField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;

- (void)cancelButtonTouched:(id)sender;
- (IBAction)loginButtonClicked:(id)sender;
@end

@implementation GTLoginViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.view setBackgroundColor:kColorGlobalBackground];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self trackScreenName:@"Login"];
}

#pragma mark - ButtonActions
- (void)cancelButtonTouched:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)loginButtonClicked:(id)sender{
    NSString *email = self.emailField.text;
    NSString *password = self.passwordField.text;

    if ([GTValidations validateEmail:email] == NO){
        [self displayFailureMessage:@"Please enter a valid email id."];
        return;
    }
    
    if ([GTValidations validatePassword:password] == NO) {
        [self displayFailureMessage:@"A valid password must be more than 6 characters."];
        return;
    }
    
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.netStatus != kNotReachable) {
        [self displayActivityIndicatorViewWithMessage:@"Signing in..."];
        [User
         loginUserWithUserId:email
         password:password
         sucess:^(NSString *successMessage) {
             
             [self removeLoginViewController];
             [self hideStatusMessage];
             
         } failure:^(NSError *error) {

             [[GTAnalyticsManager sharedInstance] logLoginFailure];
             [self hideStatusMessage];

             TALog(@"error: %@",error);
             NSMutableString *errorDescription = [[NSMutableString alloc] initWithString:@"SignIn failed"];
             if ([[error userInfo] valueForKey:@"errorDescription"] !=nil) {
                 errorDescription = [[error userInfo] valueForKey:@"errorDescription"];
             }
             SIAlertView *alert = [[SIAlertView alloc] initWithTitle:nil andMessage:errorDescription];
             [alert setTransitionStyle:SIAlertViewTransitionStyleDropDown];
             [alert setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
             [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
             [alert show];
         }];

    }else{
        [self displayNoInternetMessage];
    }
}


- (void)removeLoginViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - textField delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == _emailField) {
        [self.passwordField becomeFirstResponder];
    }else{
        [self.passwordField resignFirstResponder];
        [self.emailField resignFirstResponder];
        [self loginButtonClicked:nil];
    }
    return YES;
}

@end
