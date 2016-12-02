//
//  GTPhoneNumberVerificationController.m
//  goTogether
//
//  Created by shirish on 19/03/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTPhoneNumberVerificationController.h"
#import "goTogetherAppDelegate.h"
#import "User.h"
#import "CoreData+MagicalRecord.h"
#import "NSManagedObject+MagicalRecord.h"
#import "GTValidations.h"
#import "UIButton+GTExtensions.h"
#import "NSString+GTExtensions.h"

@interface GTPhoneNumberVerificationController ()

@property (nonatomic, strong) IBOutlet UITextField *phoneNumberField;
@property (nonatomic, strong) IBOutlet UITextField *pinField;

@end

@implementation GTPhoneNumberVerificationController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setupCancelButton];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self trackScreenName:@"PhoneVerify"];
}

#pragma mark - button actions

- (void)setupCancelButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTouched:)];
}

- (void)cancelButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)verifyPinTouched:(id)sender {
    NSString *userEnteredPin = [_pinField text];

    if ([userEnteredPin isStringAvailable] == NO) {
        [self displayFailureMessage:@"Please enter a valid PIN."];
        return;
    }
    
    [self displayActivityIndicatorViewWithMessage:@"Verifying..."];
    
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.netStatus != kNotReachable) {
        
        User *currentUser = [User currentUser];
        [User
         verifyPin:userEnteredPin
         sucess:^(NSString *successMessage) {
             
             [self displaySucessMessage:@"Verified!"];
             [currentUser setPhoneNumberVerifiedValue:YES];
             
             [[NSNotificationCenter defaultCenter]
              postNotificationName:kNotificationType_phoneVerified object:nil];
             
             NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
             [defaultContext saveToPersistentStoreWithCompletion:nil];
             [self dismissViewControllerAnimated:YES completion:nil];
             
         } failure:^(NSError *error) {
             NSString *errorDescription = [error.userInfo valueForKey:@"errorDescription"];
             if (errorDescription == nil) {
                 errorDescription = @"Failed to verify. Please try again!";
             }
             TALog(@"error: %@",error);
             [self displayFailureMessage:errorDescription];
         }];
    }else{
        [self displayNoInternetMessage];
    }
}

- (void)sendPinButtonTouched:(id)sender{
    
    [self.phoneNumberField resignFirstResponder];
    
    if ([GTValidations validatePhoneNumber:self.phoneNumberField.text] == NO) {
        [self displayFailureMessage:@"Please enter a valid phone number."];
        return;
    }
    
    NSString *fullNumber =  nil;
    NSString *phoneNumberString = self.phoneNumberField.text;
    if ([GTValidations doesPhoneNumberContainCountryCode:phoneNumberString] == NO) {
        fullNumber = [GTValidations makeInternationalPhoneNumber:phoneNumberString];
    }else {
        fullNumber = [NSString stringWithFormat:@"+%@",phoneNumberString];
    }
    
    NSString *alertMessage = [NSString stringWithFormat:@"We are sending a verification code to %@. Press OK to continue.",fullNumber];

    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:nil andMessage:alertMessage];
    [alert setTransitionStyle:SIAlertViewTransitionStyleDropDown];
    [alert setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
    
    [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {

        [self displayActivityIndicatorViewWithMessage:@"Generating a PIN..."];
        [User
         sendPinToPhoneNumber:fullNumber
         Success:^(id success) {
             [self displaySucessMessage:@"A PIN has been sent to your Phone Number."];
             
         } failure:^(NSError *error) {
             NSString *errorDescription = [error.userInfo valueForKey:@"errorDescription"];
             if (errorDescription == nil) {
                 errorDescription = @"Sending PIN failed!";
             }
             TALog(@"error: %@",error);
             [self displayFailureMessage:errorDescription];
         }];
    }];
    
    [alert addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
    }];
    [alert show];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0 && indexPath.row == 1) {
        [self sendPinButtonTouched:nil];
    }else {
        [self verifyPinTouched:nil];
    }
}

@end
