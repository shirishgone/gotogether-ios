//
//  GTAboutViewController.m
//  goTogether
//
//  Created by shirish gone on 06/04/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTAboutViewController.h"
#import "TAFacebookManager.h"
#import "GTTwitterManager.h"
#import <MessageUI/MessageUI.h>
#import "Mobihelp.h"

@interface GTAboutViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation GTAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self trackScreenName:@"About"];
}

- (void)showCancelButton {
    [self setupCancelButton];
}

- (void)setupCancelButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTouched:)];
}

- (void)cancelButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *shareMessage = [[GTDataManager sharedInstance] shareMessage];

    
    if (indexPath.section == 0){
        if (indexPath.row == 0) {
            [[Mobihelp sharedInstance] presentSupport:self];
        }else if (indexPath.row == 1){
            [self suggestAFeature];
        }
    }else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                [self shareOnFacebook:shareMessage];
                break;
            case 1:
                [self shareOnTwitter:shareMessage];
                break;
            case 2:
                [self shareOnWhatsApp:shareMessage];
                break;
            case 3:
                [self shareViaEmail:shareMessage];
                break;
            default:
                break;
        }
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            [self rateTheApp];
        }else if (indexPath.row == 1){
            [self showTermsOfService];
        }else {
            [self showPrivacyPolicy];
        }
    }
}

- (IBAction)callButtonTouched:(id)sender {
    [self callSupport];
}

#pragma mark -

- (void)showPrivacyPolicy {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kPrivacyPolicyUrl]];
}

- (void)showTermsOfService {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kTermsOfServiceUrl]];
}

- (void)callSupport {
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:kSupportPhoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];

}
- (void)suggestAFeature {
    NSString *emailTitle = @"Suggest a feature.";
    NSArray *toRecipents = [NSArray arrayWithObject:@"contact@gotogether.mobi"];
    [self presentEmailControllerWithTitle:emailTitle message:nil toRecepients:toRecipents];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            TALog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            TALog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            [self displaySucessMessage:@"Mail Sent!"];
            break;
        case MFMailComposeResultFailed:
            [self displayFailureMessage:@"Mail sent failure"];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}



- (void)rateTheApp {
    NSString* url = [NSString stringWithFormat:@"https://itunes.apple.com/in/app/gotogether/id%@?mt=8", kAppStore_appId];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:url]];
}

- (void)shareOnFacebook:(NSString *)message{
    [[TAFacebookManager sharedInstance] shareOnFacebookWithMessage:message];
}

- (void)shareOnTwitter:(NSString *)message{
    [[GTTwitterManager sharedInstance] shareOnTwitterWithMessage:message];
}

- (void)shareOnWhatsApp:(NSString *)message{
    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",message];
    NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    } else {
        [self displayFailureMessage:@"Your device doesn't seem to have WhatsApp installed."];
    }
}

- (void)shareViaEmail:(NSString *)message{

    NSString *emailTitle = @"gotogether - Intercity Ridesharing Network.";
    [self presentEmailControllerWithTitle:emailTitle message:message toRecepients:nil];
}

- (void)presentEmailControllerWithTitle:(NSString *)title
                             message:(NSString *)message
                           toRecepients:(NSArray *)recepients{
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:title];
        [mc setMessageBody:message isHTML:NO];
        [mc setToRecipients:recepients];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }else{
        NSString *message = @"Email not configured on this device.";
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:message];
        [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDestructive handler:nil];
        [alertView setTransitionStyle:SIAlertViewTransitionStyleDropDown];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
        [alertView show];
    }
}
@end
