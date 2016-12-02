//
//  GTTwitterManager.m
//  goTogether
//
//  Created by Shirish on 3/7/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTTwitterManager.h"
#import <Social/Social.h>

static GTTwitterManager *sharedInstance = nil;

@interface  GTTwitterManager()
@end

@implementation GTTwitterManager

+(GTTwitterManager*)sharedInstance
{
    @synchronized([GTTwitterManager class])
    {
        if (!sharedInstance){
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
    return nil;
}

- (void)shareOnTwitterWithMessage:(NSString *)message{

    if ([self userHasAccessToTwitter]){
        [self presentTwitterComposerWithMessage:message];
    }else{
        [self getTwitterAccessWithsuccess:^(id success) {
            [self presentTwitterComposerWithMessage:message];
        } failure:^(NSError *error) {
            
            NSString *titleString = @"Twitter Authentication Failed.";
            NSString *messageString = @"Please check the Twitter account setup on your device.";

            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:titleString
                                                             andMessage:messageString];
            [alertView addButtonWithTitle:@"OK"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:nil];

            [alertView setTransitionStyle:SIAlertViewTransitionStyleDropDown];
            [alertView setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
            [alertView show];
        }];
    }
}

- (void)presentTwitterComposerWithMessage:(NSString *)message{
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *) [[UIApplication sharedApplication] delegate];
    SLComposeViewController *tweetSheet =
    [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [tweetSheet setInitialText:message];
    [appDelegate.window.rootViewController presentViewController:tweetSheet animated:YES completion:nil];
}

#pragma mark - private methods

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)getTwitterAccessWithsuccess:(void (^)(id success))handleSuccess
                            failure:(void (^)(NSError *error))handleFailure;
{
    
    //  Step 0: Check that the user has local Twitter accounts
    if ([self userHasAccessToTwitter] == NO) {
        
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType =
        [accountStore accountTypeWithAccountTypeIdentifier:
         ACAccountTypeIdentifierTwitter];
        
        [accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             
             if (granted) {
                 handleSuccess(nil);
             }
             else {
                 handleFailure(error);
                 // Access was not granted, or an error occurred
                 TALog(@"%@", [error localizedDescription]);
             }
         }];
    }
}

@end