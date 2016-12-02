//
//  GTProfileParentViewController.m
//  goTogether
//
//  Created by Pavan Krishna on 24/04/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "GTProfileParentViewController.h"
#import "GTProfileViewController.h"
#import "GTMyRidesViewController.h"
#import "GTRideDetailsParentViewController.h"
#import "goTogetherAppDelegate.h"
#import "GTEditProfileViewController.h"
#import "GTAboutViewController.h"
#import "GTAddVehicleViewController.h"
#import "GTFriendsListViewController.h"

#define kSegmentBarHeight  29.0


@interface GTProfileParentViewController ()
<UIActionSheetDelegate,
GTEditProfileDelegate,
GTAddVehicleDelegate>

@property (strong, nonatomic) IBOutlet UIView *displayView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) GTProfileViewController *profileViewController;
@property (strong, nonatomic) GTMyRidesViewController *myEventsViewController;

- (IBAction)friendsButtonTouched:(id)sender;
- (IBAction)segmentButtonClicked:(id)sender;
@end

@implementation GTProfileParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self instantiateProfileViewController];
    [self instantiateEventsViewController];
    [self segmentButtonClicked:nil];
    [self setTitle];
}

- (void)setUser:(User *)user {
    _user = user;
}

- (void)showUserDetailsForUserId:(NSString *)userId {
    [User
     getProfileDetailsForUserId:userId
     sucess:^(User *user) {
         self.user = user;
         [self reloadUserDetails];
     } failure:^(NSError *error) {
     }];
}

- (void)loadUserProfileDetails {
    if (self.user !=nil) {
        [User
         getProfileDetailsForUserId:self.user.userId
         sucess:^(User *user) {
             self.user = user;
             [self reloadUserDetails];
         } failure:^(NSError *error) {
         }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueIdentifier_profileToEditProfile]) {
        UINavigationController *destinationNavController = [segue destinationViewController];
        GTEditProfileViewController *editProfileViewController = [[destinationNavController viewControllers] objectAtIndex:0];
        [editProfileViewController setDelegate:self];
    }
}

- (void)phoneVerified:(id)sender {
    [self reloadUserDetails];
}

- (void)reloadUserDetails {
    if (self.profileViewController !=nil) {
        [self.profileViewController setUser:self.user];
    }
    if (self.myEventsViewController !=nil) {
//        [self.myEventsViewController setUser:self.user];
    }
}

- (void)setTitle {
    if (_user.name == nil) {
        self.navigationItem.title = @"Profile";
    }
    else{
        self.navigationItem.title = _user.name;
    }
}

- (void)instantiateProfileViewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier bundle:nil];
    self.profileViewController =
    [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_profile];
    
    self.profileViewController.view.frame = [self displayFrame];
    [self addChildViewController:_profileViewController];
}

- (void)instantiateEventsViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier bundle:nil];
    self.myEventsViewController =
    [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_myRides];
    
    self.myEventsViewController.view.frame = [self displayFrame];
    [self addChildViewController:_myEventsViewController];
//    [self.myEventsViewController setUser:self.user];
}

#pragma mark - push to event Details

- (void)pushToEventDetailsWithData:(Event *)eventDetails {
    [self switchToController:_myEventsViewController];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier_rideDetails
                                                             bundle:[NSBundle mainBundle]];
    GTRideDetailsParentViewController *rideDetailsViewController =
    [mainStoryboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_rideDetailsParent];
    [rideDetailsViewController setEvent:eventDetails];
    [self.navigationController pushViewController:rideDetailsViewController animated:YES];
}

#pragma mark - Child Parent switching

- (IBAction)segmentButtonClicked:(id)sender {
    if (self.segmentControl.selectedSegmentIndex == 0) {
        [self switchToController:_profileViewController];
    }
    else if (self.segmentControl.selectedSegmentIndex == 1)
    {
        [self switchToController:_myEventsViewController];
    }
}

- (void)switchToController:(UIViewController *)newVC {
    if (newVC) {
        if (newVC == self.presentedViewController)
            return;
        
        if([self.presentedViewController isViewLoaded]) {
            [self.presentedViewController.view removeFromSuperview];
        }
        
        newVC.view.frame = [self displayFrame];
        [self.displayView addSubview:newVC.view];
        self.presentedViewController.view = newVC.view;
    }
}

- (CGRect)displayFrame {
    return  _displayView.bounds;
}

@end
