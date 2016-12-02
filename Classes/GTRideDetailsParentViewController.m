//
//  GTRideDetailsParentViewController.m
//  goTogether
//
//  Created by shirish gone on 07/07/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTRideDetailsParentViewController.h"
#import "GTRideDetailsViewController.h"
#import "GTTravellersListViewController.h"
#import "GTCommentsViewController.h"
#import <MessageUI/MessageUI.h>
#import "GTAddViewController.h"
#import <Social/Social.h>
#import "GTTwitterManager.h"
#import "TAFacebookManager.h"
#import "GTProfileViewController.h"

@interface GTRideDetailsParentViewController ()
<GTDeleteEventDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *displayView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) UIViewController *viewController;

@property (strong, nonatomic) GTRideDetailsViewController *rideDetailsViewController;
@property (strong, nonatomic) GTTravellersListViewController *travellersListViewController;
@property (strong, nonatomic) GTCommentsViewController *commentsViewController;
@property (nonatomic, strong) GTProfileViewController *profileViewController;


@property(nonatomic, assign) BOOL reloading;

@end

@implementation GTRideDetailsParentViewController

- (void)awakeFromNib {
    [self instantiateChildViewControllers];
}

- (void)instantiateChildViewControllers {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier_rideDetails
                                                         bundle:nil];
    
    self.rideDetailsViewController =
    [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_rideDetails];
    
    self.travellersListViewController =
    [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_rideDetailsTravellersList];

    self.commentsViewController =
    [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_messages];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self trackScreenName:self.title];
    
    [self setupNotificationHandlers];
    [self setupRightBarButton];
    [self showDetailsViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setEvent:(Event *)event {
    _event = event;
    [self setTitleForEvent:event];

    self.rideDetailsViewController.event = self.event;
    self.commentsViewController.event = self.event;
    self.travellersListViewController.event = self.event;
}

- (void)setTitleForEvent:(Event *)event {    
    NSMutableString *sourceName = [NSMutableString stringWithString:event.sourceName];
    NSMutableString *destinationName = [NSMutableString stringWithString:event.destinationName];
    NSString *sourceDestinationString = [NSString stringWithFormat:@"%@ to %@",sourceName, destinationName];
    [self setTitle:sourceDestinationString];
}

#pragma mark - Presented Cancel Button
- (void)setIsPresented:(BOOL)isPresented {
    _isPresented = isPresented;
    [self showCancelButton];
}

- (void)showCancelButton {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTouched:)];
}

- (void)cancelButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Child Parent switching

- (void)showDetailsViewController {
    self.segmentControl.selectedSegmentIndex = 0;
    [self segmentButtonClicked:nil];
}

- (IBAction)segmentButtonClicked:(id)sender {
    if (self.segmentControl.selectedSegmentIndex == 0) {
        [self switchToController:_rideDetailsViewController];
    }else if (self.segmentControl.selectedSegmentIndex == 1) {
        [self switchToController:_travellersListViewController];
    }else if (self.segmentControl.selectedSegmentIndex == 2) {
        [self switchToController:_commentsViewController];
    }
}

- (void)switchToController:(UIViewController *)newVC {

    // Remove child view controller
    if (self.viewController) {
        [self.viewController.view removeFromSuperview];
        [self.viewController removeFromParentViewController];
    }
    
    if (newVC) {
        // Add Child view controller
        [newVC.view setFrame:[self displayFrameBounds]];
        [self.displayView addSubview:newVC.view];
        /*Calling the addChildViewController: method also calls
         the child’s willMoveToParentViewController: method automatically */
        [self addChildViewController:newVC];
        [newVC didMoveToParentViewController:self];

        self.viewController = newVC;
    }
}

- (CGRect)displayFrameBounds {
    return _displayView.bounds;
}

#pragma mark -

- (void)setupNotificationHandlers {
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(eventUpdated:)
     name:kNotificaionType_eventUpdated
     object:nil];
}

- (void)reloadData {
    [self.rideDetailsViewController setEvent:_event];
    [self.commentsViewController setEvent:_event];
    [self.travellersListViewController setEvent:_event];
}

#pragma mark -

- (void)setupRightBarButton {
    if ([_event isCurrentUserEvent]) {
        UIBarButtonItem *actionBarButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                      target:self
                                                      action:@selector(showSocialSharingSheet:)
         ];
        UIBarButtonItem *editButton =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                      target:self
                                                      action:@selector(editEventButtonClicked:)
         ];
        [self.navigationItem setRightBarButtonItems:@[editButton,actionBarButton]];
    }
}

#pragma mark - action handlers

- (NSString *)eventDetailShareString {
    if ([self.event userTypeValue] == userType_driving) {
        return [NSString stringWithFormat:@"Hey, need a ride from %@ to %@ ? Catch me on http://gotogether.mobi",self.event.sourceName,self.event.destinationName];
    }else{
        return [NSString stringWithFormat:@"Hey, can I get a ride from %@ to %@ ? sent via http://gotogether.mobi",self.event.sourceName,self.event.destinationName];
    }
}

- (void)editEventButtonClicked:(id)sender {
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier bundle:[NSBundle mainBundle]];
    
    GTAddViewController *addViewController =
    [mainStoryBoard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_add];
    addViewController.eventMode = eventMode_editEvent;
    addViewController.event = self.event;
    addViewController.delegate = self;
    
    UINavigationController *updateEventNavController = [[UINavigationController alloc] initWithRootViewController:addViewController];
    [self presentViewController:updateEventNavController animated:YES completion:nil];
}

- (void)showSocialSharingSheet:(id)sender {
    UIActionSheet *actionSheet =
    [[UIActionSheet alloc] initWithTitle:@"Tell your friends to join your ride."
                                delegate:self
                       cancelButtonTitle:@"Cancel"
                  destructiveButtonTitle:nil
                       otherButtonTitles:@"Facebook", @"Twitter", @"Whats App", @"Mail",nil];
    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    [actionSheet showInView:appDelegate.window];
}

#pragma mark - action sheet delegates

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [self shareOnFacebookTouched:nil];
            break;
        case 1:
            [self shareOnTwitterTouched:nil];
            break;
        case 2:
            [self shareViaWhatsApp:nil];
            break;
        case 3:
            [self shareViaEmail:nil];
            break;
            
        default:
            break;
    }
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

#pragma mark - Share via Email

- (void)shareViaEmail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        // Email Subject
        NSString *emailTitle = @"Share your ride on gotogether.";
        NSString *emailBody = [self eventDetailShareString];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:emailBody isHTML:NO];
        
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

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
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
            [self displayFailureMessage:@"Sending failed!"];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)shareViaWhatsApp:(id)sender{
    
    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",[self eventDetailShareString]];
    NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
        
    } else {
        [self displayFailureMessage:@"Your device doesn't seem to have WhatsApp installed."];
    }
}

#pragma mark - Share via Facebook

- (void)shareOnFacebookTouched:(id)sender {
    [[TAFacebookManager sharedInstance] shareOnFacebookWithMessage:[self eventDetailShareString]];
}


#pragma mark - Share via Twitter

- (void)shareOnTwitterTouched:(id)sender {
    [[GTTwitterManager sharedInstance] shareOnTwitterWithMessage:[self eventDetailShareString]];
}

#pragma mark -

- (void)postEventUpdatedNotificationWithEvent:(Event *)event {
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:event
                 forKey:kNotificaionObject_updatedEvent];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNotificaionType_eventUpdated
     object:nil
     userInfo:userInfo];
}

- (void)updateEvent {
    
    [self displayActivityIndicatorViewWithMessage:@"Updating..."];
    [Event
     getEventDetailsWithEventId:_event.eventId
     sucess:^(Event *event) {
         [self postEventUpdatedNotificationWithEvent:self.event];
         [self setEvent:event];

         [self reloadData];
         [self hideStatusMessage];
     } failure:^(NSError *error) {
         [self hideStatusMessage];
         [self displayFailureMessage:@"Error reloading event."];
     }];
}

#pragma mark - event updated handler

- (void)eventUpdated:(id)sender {
    
    NSNotification *notification = sender;
    if ([[notification name] isEqualToString:kNotificaionType_eventUpdated]) {
        NSDictionary* userInfo = [notification userInfo];
        Event *event= [userInfo objectForKey:kNotificaionObject_updatedEvent];
        self.event = event;
        [self reloadData];
    }
}

#pragma mark - delete event delegate

- (void)eventDeleted {
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark load user details

- (void)pushToShowUserWithId:(NSString *)userId {
    User *user = [User userForUserId:userId];
    if (user == nil) {
        [self displayActivityIndicatorViewWithMessage:@"Fetching user details..."];
        [User
         getProfileDetailsForUserId:userId
         sucess:^(User *user) {
             [self hideStatusMessage];
             [self loadTravellerProfileWithUserDetails:user];
         } failure:^(NSError *error) {
             [self displayFailureMessage:@"User details request failed!"];
         }];
        
    }else{
        [self loadTravellerProfileWithUserDetails:user];
        
        [User
         getProfileDetailsForUserId:userId
         sucess:^(User *user) {
             [self.profileViewController setUser:user];
         } failure:^(NSError *error) {
         }];
    }
}

- (void)loadTravellerProfileWithUserDetails:(User *)user {
    
    UIStoryboard *storyBoard =
    [UIStoryboard storyboardWithName:kStoryBoardIdentifier
                              bundle:[NSBundle mainBundle]];
    
    self.profileViewController =
    [storyBoard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_profile];
    [_profileViewController setUser:user];
    [self.navigationController pushViewController:_profileViewController
                                                              animated:YES];
}

@end
