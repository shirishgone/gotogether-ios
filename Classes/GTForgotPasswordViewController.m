//
//  GTForgotPasswordViewController.m
//  goTogether
//
//  Created by shirish gone on 18/08/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTForgotPasswordViewController.h"
#import "GTValidations.h"

@interface GTForgotPasswordViewController ()

@property (nonatomic, strong) IBOutlet UITextField *emailField;

- (IBAction)forgotPasswordTouched:(id)sender;

@end

@implementation GTForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBackgroundMapView];
}

- (IBAction)forgotPasswordTouched:(id)sender {
    NSString *emailId = self.emailField.text;
    if ([GTValidations validateEmail:emailId] == NO) {
        
        NSString *messageString = @"Please enter a valid email id, before you tap on forgot password.";
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:messageString];
        [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
        [alertView setTransitionStyle:SIAlertViewTransitionStyleDropDown];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
        [alertView show];
        
    }else{
        
        NSString *messageString = [NSString stringWithFormat:@"We will send your account details to %@, if an account exists on this email id. Do you want to continue?",emailId];
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Forgot password?"
                                                         andMessage:messageString];
        [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  [self forgotPasswordApiCall];
                              }];
        [alertView addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeDestructive handler:nil];
        [alertView setTransitionStyle:SIAlertViewTransitionStyleDropDown];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
        [alertView show];
    }
}

- (void)forgotPasswordApiCall{
    
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.netStatus != kNotReachable) {
        
        [self displayActivityIndicatorViewWithMessage:@"Sending account credentials..."];
        [User
         forgotPasswordForEmailId:self.emailField.text
         success:^(NSString *sucessMessage) {
             [self displaySucessMessage:@"Account credentials sent to your email id."];
         } failure:^(NSError *error) {
             
             NSMutableString *errorDescription = [[NSMutableString alloc] initWithString:@"Account credentials sending failed."];
             if ([error valueForKey:@"description"] !=nil) {
                 errorDescription = [error valueForKey:@"description"];
             }
             [self displayFailureMessage:errorDescription];
         }];
    }else{
        [self displayNoInternetMessage];
    }
}

@end
