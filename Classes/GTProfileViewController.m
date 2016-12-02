//
//  GTProfileViewController.m
//  goTogether
//
//  Created by shirish on 21/03/13.
//  Copyright (c) 2013 GoTogether. All rights reserved.
//

#import "GTProfileViewController.h"
#import "GCPlaceholderTextView.h"
#import "TADateTimePicker.h"
#import "goTogetherAppDelegate.h"
#import "Event.h"
#import "UIImage+TAExtensions.h"
#import "GTFriendsListViewController.h"
#import "GTMyRidesViewController.h"
#import "UIImage+TAExtensions.h"
#import "GTProfileParentViewController.h"
#import "TAFacebookManager.h"
#import "GTProfileVerificationTableViewCell.h"
#import "GTAddVehicleViewController.h"
#import "GTPhoneNumberVerificationController.h"
#import "GTProfileTable_headerView.h"
#import "GTFacebookPublicProfileViewController.h"
#import "GTAboutViewController.h"
#import "GTMutualFriend.h"
#import "GTMutualFriendsView.h"
#import "GTEditProfileViewController.h"


#import "GTProfilePersonalDetailsTableCell.h"
#import "GTProfileSocialProfileTableViewCell.h"
#import "GTProfileVehicleTableCell.h"
#import "GTProfileVerificationTableViewCell.h"

#define kCellHeight_default 50.0
#define kCellHeight_description 60.0
#define kPhoneCallAlert 2
#define kActionSheet_logout 2

NSString *kCellID_personal = @"personal_details";
NSString *kCellID_mutualFriends = @"mutual_friends";
NSString *kCellID_verifications = @"verifications";
NSString *kCellID_vehicle = @"vehicle";

@interface GTProfileViewController ()
<UIImagePickerControllerDelegate,
UIActionSheetDelegate,
UITableViewDataSource,
GTAddVehicleDelegate,
UITableViewDelegate,
GTEditProfileDelegate>
{
    UIImagePickerController *imagePickerController;
}

@property (nonatomic, weak) IBOutlet GTProfileTable_headerView *tableHeaderView;

//@property (nonatomic, weak) IBOutlet GTProfilePersonalDetailsTableCell *personalDetailsCell;
//@property (nonatomic, weak) IBOutlet GTProfileSocialProfileTableViewCell *socialProfileCell;
//@property (nonatomic, weak) IBOutlet GTProfileVehicleTableCell *vehicleCell;
//@property (nonatomic, weak) IBOutlet GTProfileVerificationTableViewCell *verificationsCell;
@property (nonatomic, readwrite) BOOL isCurrentUser;

@property (nonatomic, strong) NSArray *mutualFriends;

@end

@implementation GTProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Profile";
    [self.tableView setBackgroundColor:kColorGlobalBackground];
    [self reloadProfileDetails];
    [self addPhoneVerificationNotificationHandler];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self trackScreenName:@"Profile"];
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

#pragma mark - nav buttons

- (void)addFriendsButton {
    UIBarButtonItem *friendsButton =
    [[UIBarButtonItem alloc]
     initWithImage:[UIImage imageNamed:@"nav_friends"]
     style:UIBarButtonItemStylePlain
     target:self
     action:@selector(friendsButtonTouched:)
     ];
    
    self.navigationItem.leftBarButtonItem = friendsButton;
}

- (void)addSettingsButton {
    UIBarButtonItem *settingsButton =
    [[UIBarButtonItem alloc]
     initWithImage:[UIImage imageNamed:@"nav_setttings"]
     style:UIBarButtonItemStylePlain
     target:self
     action:@selector(settingsButtonTouched:)
     ];
    
    self.navigationItem.rightBarButtonItem = settingsButton;
}


#pragma mark - Loading Data

- (void)showCurrentUser {
    self.isCurrentUser = YES;
    self.user = [User currentUser];
    [self refresh:nil];
    [self addSettingsButton];
    [self loadUserProfileDetails];
    [self addFriendsButton];
}

- (void)setUser:(User *)user {
    _user = user;
    [self reloadProfileDetails];
}

- (void)reloadProfileDetails {
    if (_user != nil) {
        self.isCurrentUser = NO;
        [self reloadProfileDetailsUI];
        [self fetchMutualFriends];
    }else{
        self.isCurrentUser = YES;
        _user = [User currentUser];
        [self reloadProfileDetailsUI];
    }
}

- (void)reloadProfileDetailsUI {
    [self.tableHeaderView setUserDetails:_user];
    [self.tableView reloadData];
}

- (void)loadUserProfileDetails {
    if (self.user !=nil) {
        [User
         getProfileDetailsForUserId:self.user.userId
         sucess:^(User *user) {
             self.user = user;
             [self reloadProfileDetails];
         } failure:^(NSError *error) {
         }];
    }
}

- (void)fetchMutualFriends {

    if ([self.user isCurrentUser] == NO) {
        [self displayActivityIndicatorViewWithMessage:@"Loading Mutual Friends..."];
        [Friend
         fetchMutualFriendsForUserId:self.user.userId
         handleSuccess:^(NSArray *mutualFriends) {
             [self hideStatusMessage];
             
             self.mutualFriends = mutualFriends;
             [self reloadProfileDetailsUI];
         } failure:^(NSError *error) {
                                  
         }];
    }
    
}

- (BOOL)isCurrentUser {
    
    return [self.user isCurrentUser];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.isCurrentUser) {
        return 3;
    }else {
        return 4;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = nil;
    if (self.isCurrentUser) {
        if (indexPath.section == 0) {
            cellIdentifier = kCellID_personal;
        }else if (indexPath.section == 1){
            cellIdentifier = kCellID_verifications;
        }else{
            cellIdentifier = kCellID_vehicle;
        }
    }else{
        if (indexPath.section == 0) {
            cellIdentifier = kCellID_personal;
        }else if (indexPath.section == 1){
            cellIdentifier = kCellID_mutualFriends;
        }else if (indexPath.section == 2){
            cellIdentifier = kCellID_verifications;
        }else{
            cellIdentifier = kCellID_vehicle;
        }
    }
    return cellIdentifier;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier =  [self cellIdentifierForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                            forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[GTProfilePersonalDetailsTableCell class]]) {
        GTProfilePersonalDetailsTableCell *personalCell = (GTProfilePersonalDetailsTableCell *)cell;
        [personalCell setUser:self.user];
    }else if ([cell isKindOfClass:[GTProfileSocialProfileTableViewCell  class]]) {
        GTProfileSocialProfileTableViewCell *socialCell = (GTProfileSocialProfileTableViewCell *)cell;
        [socialCell.mutualFriendsView setMutualFriendsArray:self.mutualFriends];
    }else if ([cell isKindOfClass:[GTProfileVerificationTableViewCell class]]) {
        GTProfileVerificationTableViewCell *verificationsCell = (GTProfileVerificationTableViewCell *)cell;
        if (self.user.phoneNumberVerifiedValue == YES) {
            [verificationsCell setVerificationType:UserPhoneVerified];
         }else{
             if ([self.user isCurrentUser]) {
                 [verificationsCell setVerificationType:UserPhoneVerifyNow];
             }else{
                 [verificationsCell setVerificationType:UserPhoneNotVerified];
             }
         }
    }else {
        GTProfileVehicleTableCell *vehicleCell = (GTProfileVehicleTableCell *)cell;
        [vehicleCell setVehicle:self.user.vehicle];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.isCurrentUser) {
        if (indexPath.section == 0) {
            [self showEditProfileScreen];
        }else if (indexPath.section == 1){
            if (self.user.phoneNumberVerifiedValue == NO) {
                goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)
                [[UIApplication sharedApplication]delegate];
                [appDelegate.rootViewController presentPhoneVerificationView];
            }
        }else {
            [self showEditVehicleDetails];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height = 0.0;
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    if ([cellIdentifier isEqualToString:kCellID_personal]) {
        height = 150.0;
    }else if ([cellIdentifier isEqualToString:kCellID_mutualFriends]){
        height = 70.0;
    }else if ([cellIdentifier isEqualToString:kCellID_verifications]){
        height = 45.0;
    }else{
        height = 45.0;
    }
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 30.0)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 0.0, 200.0, 30.0)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:[self titleForSectionHeader:section]];
    [label setTextColor:[UIColor grayColor]];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0]];
    
    [headerView addSubview:label];
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}


- (NSString *)titleForSectionHeader:(NSInteger)section {
    NSString *headerTitle = @"";
    if (self.isCurrentUser) {
        switch (section) {
            case 0:
                headerTitle = @"Personal Details";
                break;
            case 1:
                headerTitle = @"Verifications";
                break;
            case 2:
                headerTitle = @"Vehicle Details";
                break;
            default:
                break;
        }
    }else {
        switch (section) {
            case 0:
                headerTitle = @"Personal Details";
                break;
            case 1:
                headerTitle = @"Mutual Friends";
                break;
            case 2:
                headerTitle = @"Verifications";
                break;
            case 3:
                headerTitle = @"Vehicle Details";
                break;
            default:
                break;
        }
    }
    return headerTitle;
}



//#pragma mark - Facebook
//
//- (void)facebookButtonTouched {
//    if ([self.user isUserFacebookConnected]) {
//        [self showFacebookPublicProfileWithId:self.user.facebookId];
//    }else {
//        NSString *message = [NSString stringWithFormat:@"%@ did not connect with Facebook.",
//                             self.user.name];
//        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:message];
//        [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDestructive handler:nil];
//        [alertView setTransitionStyle:SIAlertViewTransitionStyleDropDown];
//        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
//        [alertView show];
//    }
//}
//
//- (void)showFacebookPublicProfileWithId:(NSString *)facebookId {
//    NSURL *url = [NSURL URLWithString:[NSString  stringWithFormat:@"fb://profile/%@",facebookId]];
//    [[UIApplication sharedApplication] openURL:url];
//    
//    if ([[UIApplication sharedApplication] canOpenURL:url]){
//        [[UIApplication sharedApplication] openURL:url];
//    }
//    else {
//        GTFacebookPublicProfileViewController *facebookProfileViewController = [[GTFacebookPublicProfileViewController alloc] init];
//        facebookProfileViewController.hidesBottomBarWhenPushed = YES;
//        facebookProfileViewController.facebookId = facebookId;
//        [self.navigationController pushViewController:facebookProfileViewController animated:YES];
//    }
//}

#pragma mark - settings methods

- (void)settingsButtonTouched:(id)sender{
    
    NSString *vehicleDetailsString = nil;
    if ([[User currentUser] vehicle] !=nil) {
        vehicleDetailsString = @"Edit Vehicle Details";
    }else {
        vehicleDetailsString = @"Add Vehicle Details";
    }
    
    UIActionSheet *logoutActionSheet =
    [[UIActionSheet alloc] initWithTitle:nil
                                delegate:self
                       cancelButtonTitle:@"Cancel"
                  destructiveButtonTitle:nil
                       otherButtonTitles:@"Edit Personal Details",
                                        vehicleDetailsString,
                                        @"Support",
                                        @"Logout",nil];
    logoutActionSheet.tag = kActionSheet_logout;
    [logoutActionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    [logoutActionSheet showInView:appDelegate.rootViewController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        [self showEditProfileScreen];
    }else if (buttonIndex == 1){
        [self showEditVehicleDetails];
    }else if (buttonIndex == 2){
        [self showAboutScreen];
    }else if (buttonIndex == 3){
        [self logoutTouched:nil];
    }
}

- (void)showAboutScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier bundle:nil];
    GTAboutViewController *aboutViewController = [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_about];
    aboutViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:aboutViewController animated:YES];
}

- (void)showEditProfileScreen {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier bundle:nil];
    GTEditProfileViewController *editProfileViewController = [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_profileEdit];
    editProfileViewController.delegate = self;
    
    UINavigationController *editNavController = [[UINavigationController alloc] initWithRootViewController:editProfileViewController];
    [self presentViewController:editNavController animated:YES completion:^{
        
    }];
}

- (void)editProfileSucceeded {
    [self reloadProfileDetails];
}

- (void)logoutTouched:(id)sender {
    NSString *messageString = @"Are you sure, you want to logout?";
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                     andMessage:messageString];
    [alertView addButtonWithTitle:@"YES" type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              [self logoutUser];
                          }];
    [alertView addButtonWithTitle:@"NO" type:SIAlertViewButtonTypeDestructive handler:nil];
    [alertView setTransitionStyle:SIAlertViewTransitionStyleDropDown];
    [alertView setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
    [alertView show];
}

- (void)logoutUser {
    [self displayActivityIndicatorViewWithMessage:@"Logging out..."];

    [User logoutUserForSuccess:^(NSString *sucessMessage) {
        [self displaySucessMessage:@"Successfully logged out."];
    } failure:^(NSError *error) {
        TALog(@"logout failed.");
    }];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNotificaionType_loggedOut
     object:nil];
}

#pragma mark - vehicle details

- (void)showEditVehicleDetails {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    GTAddVehicleViewController *addVehicleViewController = [storyBoard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_addVehicle];
    [addVehicleViewController setVehicle:self.user.vehicle];
    [addVehicleViewController setDelegate:self];
    [self.navigationController pushViewController:addVehicleViewController animated:YES];
}

- (void)vehicleDetailsAddedSuccessfully {
    [self reloadProfileDetails];
}

- (void)editVehicleSuccessful {
    [self reloadProfileDetails];
}

#pragma mark - Friends

- (void)friendsButtonTouched:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    GTFriendsListViewController *friendsListViewController = [storyBoard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_friendsList];
    [self.navigationController pushViewController:friendsListViewController animated:YES];
}

#pragma mark - Phone verification

- (void)addPhoneVerificationNotificationHandler {
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(phoneVerified:)
     name:kNotificationType_phoneVerified
     object:nil
     ];
}

- (void)phoneVerified:(id)sender {
    [self reloadProfileDetails];
}

@end
