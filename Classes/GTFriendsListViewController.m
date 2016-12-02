//
//  GTFriendsListViewController.m
//  goTogether
//
//  Created by shirish on 22/03/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTFriendsListViewController.h"
#import "GTFriendListTableCell.h"
#import "GTProfileViewController.h"
#import "goTogetherAppDelegate.h"
#import "Friend.h"
#import "UIImage+TAExtensions.h"
#import "TAFacebookManager.h"
#import "User.h"
#import "GTInviteFriendsViewController.h"
#import <MessageUI/MessageUI.h>
#import "GTTwitterManager.h"

#define kTableCellHeight 60.0f

@interface GTFriendsListViewController () <MFMailComposeViewControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *friendsList;
@property (nonatomic, strong) User *selectedUser;
@property (readwrite, nonatomic) BOOL reloading;
@property (readwrite, nonatomic) BOOL loadingFriendDetails;
@property (readwrite, nonatomic) UIView *connectToFacebookView;
@property (readwrite, nonatomic) GTProfileViewController *profileViewController;

- (void)doneLoadingTableViewData;

@end

@implementation GTFriendsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPullToRefreshForTableView:self.tableView];
    [self setupInviteButton];
    [self refresh:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self trackScreenName:@"FriendList"];
}

#pragma mark - Invite Friend

- (void)setupInviteButton {
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navbar_friends_add"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(inviteFriendsButtonTouched:)];
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

- (NSString *)message {
    return @"Hey! check out this new app, gotogether - Intercity ride-sharing app \nhttps://www.gotogether.mobi";
}

- (NSString *)emailTitle {
    return @"gotogether - Intercity ride-sharing.";
}

- (void)shareViaEmail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        // Email Subject
        NSString *emailTitle = [self emailTitle];
        NSString *emailBody = [self message];
        
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
            [self displayFailureMessage:@"Sending failed!"];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)shareViaWhatsApp:(id)sender{
    
    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",[self message]];
    NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
        
    } else {
        [self displayFailureMessage:@"Your device doesn't seem to have WhatsApp installed."];
    }
}

#pragma mark - Share via facebook

- (void)shareOnFacebookTouched:(id)sender {
    [[TAFacebookManager sharedInstance] shareOnFacebookWithMessage:[self message]];
}


#pragma mark - Share via twitter

- (void)shareOnTwitterTouched:(id)sender {
    [[GTTwitterManager sharedInstance] shareOnTwitterWithMessage:[self message]];
}

- (void)inviteFriendsButtonTouched:(id)sender {
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier bundle:[NSBundle mainBundle]];

    GTInviteFriendsViewController *inviteFriendsViewController =
    [mainStoryBoard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_inviteFriends];
    
    UINavigationController *inviteNavController = [[UINavigationController alloc] initWithRootViewController:inviteFriendsViewController];
    [self presentViewController:inviteNavController animated:YES completion:nil];
}

#pragma mark - action handlers

- (void)fetchFriendsList {
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray *friends = [[[User currentUser] friendsSet] allObjects];
    
    if ([friends count] > 0) {
        self.friendsList = friends;
        [self.tableView reloadData];
    }
    
    if (appDelegate.netStatus != kNotReachable) {
        [self displayActivityIndicatorViewWithMessage:@"Loading friends..."];
        [Friend obtainFriendsList:^(NSArray *friendIds) {
            
            if(friendIds.count == 0){
                [self displayNoResultsLabelWithMessage:@"Its fun to travel with friends. Tell your friends to join, and start sharing rides."];
            }
            else{
                [self removeNoResultsLabel];
            }
            self.friendsList = friendIds;
            [self.tableView reloadData];
            [self doneLoadingTableViewData];
            [self hideStatusMessage];
            
        } failure:^(NSError *error) {
            [self doneLoadingTableViewData];
            [self displayFailureMessage:@"Loading friends failed."];
        }];
    }
}

- (void)setFriendsList:(NSArray *)friendsList {
    _friendsList = [Friend sortFriends:friendsList];
}

#pragma mark - TableViewMethods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.friendsList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kTableCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    GTFriendListTableCell *cell = nil;
    static NSString *cellIndentifier = kCellIdentifier_friendList;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];

    if (cell == nil) {
        cell = [[GTFriendListTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                            reuseIdentifier:kCellIdentifier_friendList];
    }

    Friend * friend = [self.friendsList objectAtIndex:indexPath.row];
    [cell setName:friend.friendName];
    [self setPictureOfUser:friend.friendId
              forTableCell:cell
              forIndexPath:indexPath];
   
    return cell;
}

- (void)setPictureOfUser:(NSString *)userId
            forTableCell:(GTFriendListTableCell *)tableCell
            forIndexPath:(NSIndexPath *)indexPath {
    if ([UIImage isImageAvailableInCacheForUserId:userId]) {
        UIImage *cachedImage = [UIImage cachedImageforUserId:userId];
        [tableCell setProfilePic:cachedImage];
    }else {
        if ([UIImage isAvailableLocallyForUserId:userId]) {

            NSString *imageFilePath = [UIImage filePathForUserId:userId];
            UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
            [tableCell setProfilePic:image];
                
            [UIImage updateImageForUserId:userId
                                  success:^(UIImage *image) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          
                                          GTFriendListTableCell * cell = (GTFriendListTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                                          [cell setProfilePic:image];
                                      });
                                  } failure:^(NSError *error) {
                                  }];
        }else{
            UIImage *defaultImage = [UIImage imageNamed:@"ico_user_40"];
            [tableCell setProfilePic:defaultImage];
            [UIImage downloadImageForUserId:userId
                                    success:^(UIImage *image) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            
                                            GTFriendListTableCell * cell = (GTFriendListTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                                            [cell setProfilePic:image];
                                        });
                                    } failure:^(NSError *error) {
                                    }];
        }
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.viewMode == GTFriendsListViewModeNormal){
        if (_loadingFriendDetails == YES) {
            return;
        }else{
            Friend* friend = [self.friendsList objectAtIndex:indexPath.row];
            [self pushUserDetailsForUserId:friend.friendId];
        }
    }else if (self.viewMode == GTFriendsListViewModeSelection){
        GTFriendListTableCell *cell = (GTFriendListTableCell *)
        [self.tableView cellForRowAtIndexPath:indexPath];
        
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark){
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else{
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        
    }
}

- (void)pushUserDetailsForUserId:(NSString *)userId {

    [self displayActivityIndicatorViewWithMessage:@"Fetching user details..."];
    [User
     getProfileDetailsForUserId:userId
     sucess:^(User *user) {
         [self hideStatusMessage];
         [self showProfileOfUser:user];
     } failure:^(NSError *error) {
         [self displayFailureMessage:@"Fetching user details failed. Please try again."];
     }];
}

- (void)showProfileOfUser:(User *)user {
    
    UIStoryboard *storyBoard =
    [UIStoryboard storyboardWithName:kStoryBoardIdentifier bundle:[NSBundle mainBundle]];
    
    self.profileViewController =
    [storyBoard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_profile];
    [_profileViewController setUser:user];
    [self.navigationController pushViewController:_profileViewController
                                         animated:YES];

}

#pragma mark - Pull to refresh
- (void)refresh:(id)sender {
    if (_reloading == NO) {
        _reloading = YES;
        [self fetchFriendsList];
    }
}

- (void)doneLoadingTableViewData {
    _reloading = NO;
    [self stopRefreshing];
}

@end
