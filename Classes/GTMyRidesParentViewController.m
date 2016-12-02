//
//  GTMyRidesParentViewController.m
//  goTogether
//
//  Created by shirish gone on 11/12/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTMyRidesParentViewController.h"
#import "GTMyRidesViewController.h"

@interface GTMyRidesParentViewController ()
@property (strong, nonatomic) IBOutlet UIView *displayView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) GTMyRidesViewController *bookingsViewController;
@property (strong, nonatomic) GTMyRidesViewController *offersViewController;

@end

@implementation GTMyRidesParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Rides";

    [self instantiateBookingsViewController];
    [self instantiateOffersViewController];
    [self segmentButtonClicked:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark -
- (void)instantiateBookingsViewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier bundle:nil];
    self.bookingsViewController =
    [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_myRides];
    self.offersViewController.ridesType = myRidesType_bookings;
    
    self.bookingsViewController.view.frame = [self displayFrame];
    [self addChildViewController:self.bookingsViewController];
}

- (void)instantiateOffersViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier bundle:nil];
    self.offersViewController =
    [storyboard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_myRides];
    self.offersViewController.ridesType = myRidesType_offers;
    
    self.offersViewController.view.frame = [self displayFrame];
    [self addChildViewController:self.offersViewController];
}

#pragma mark - Child Parent switching

- (IBAction)segmentButtonClicked:(id)sender {
    if (self.segmentControl.selectedSegmentIndex == 0) {
        [self switchToController:_bookingsViewController];
    }
    else if (self.segmentControl.selectedSegmentIndex == 1)
    {
        [self switchToController:_offersViewController];
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
