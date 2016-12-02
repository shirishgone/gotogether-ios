//
//  TACoTravellerViewController.m
//  TravelApp
//
//  Created by shirish on 23/11/12.
//  Copyright (c) 2012 mutualmobile. All rights reserved.
//

#import "GTSearchEntryViewController.h"
#import "GTSearchResultsViewController.h"
#import "GTSearchGooglePlaceController.h"
#import "Place.h"
#import "TADateTimePicker.h"
#import "goTogetherAppDelegate.h"
#import "Event.h"
#import "TALocationManager.h"
#import "TAGoogleAPIManager.h"
#import "GTAnalyticsManager.h"
#import "UIView+mm_ImageAdditions.h"

@implementation GTSearchObject
@end

@interface GTSearchEntryViewController ()<TASearchLocationControllerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *fromLocationLabel;
@property (strong, nonatomic) IBOutlet UILabel *toLocationLabel;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@property (nonatomic, strong) TADateTimePicker *datePicker;
@property (nonatomic, strong) GTSearchObject *searchObject;
@property (readwrite, nonatomic) GTSearchLocationType currentSearchType;
@property (nonatomic, copy) NSArray *searchResults;
- (IBAction)cancelButtonTouched:(id)sender;
@end

@implementation GTSearchEntryViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initialiseData];
    [self initialiseDatePicker];
    [self reloadData];
    [UIButton addBorderToButton:self.searchButton];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self trackScreenName:@"SearchEntry"];
}

#pragma mark - initialisation methods
- (void)reloadData {
    if (_searchObject.sourcePlace !=nil) {
        [_fromLocationLabel setText:_searchObject.sourcePlace.displayName];
    }
    if (_searchObject.destinationPlace !=nil) {
        [_toLocationLabel setText:_searchObject.destinationPlace.displayName];
    }
    if (_searchObject.date !=nil) {
        NSString *dateString = [NSDate display_dateStringForSearchDate:_searchObject.date];
        [_dateLabel setText:dateString];
    }
}

- (void)initialiseData {
    self.searchObject = [[GTSearchObject alloc] init];
    [self.searchObject setDate:[NSDate date]];
//    [self setSourceAsCurrentLocation];
    [self reloadData];
}

- (void)initialiseDatePicker {
    if (_datePicker == nil) {
        _datePicker = [[TADateTimePicker alloc]
                       initWithFrame:CGRectMake(0,
                                                self.view.frame.size.height - kDatePickerHeight,
                                                self.view.frame.size.width,
                                                kDatePickerHeight)];
        [_datePicker setMode:UIDatePickerModeDate];
        [_datePicker addTargetForDoneButton:self action:@selector(datePickerDoneButtonTapped:)];
    }    
}

- (void)setSourceAsCurrentLocation {
    
    TALocationManager *locationManager = [TALocationManager sharedInstance];
    TAGoogleAPIManager *googleAPIManager = [TAGoogleAPIManager sharedInstance];
    [self displayActivityIndicatorViewWithMessage:@"Fetching current location...."];
    [googleAPIManager
     fetchLocationNameForLatitude:locationManager.currentLocation.coordinate.latitude
     longitude:locationManager.currentLocation.coordinate.longitude
     ifSucess:^(Place *place) {
         
         [self hideStatusMessage];
         [self.searchObject setSourcePlace:place];
         [self reloadData];
     } ifFailure:^(NSError *error) {;
         [self hideStatusMessage];
     }];
}

#pragma mark - table view delegates
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [UIView headerViewWithTitle:@" "];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self toLocationTouched:nil];
        }else if(indexPath.row == 1){
            [self fromLocationTouched:nil];
        }else{
            [self showDatePicker];
        }
    }else if (indexPath.section == 1){
        [self searchButtonTouched:nil];
    }
}

#pragma mark - action handler methods
- (IBAction)cancelButtonTouched:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchButtonTouched:(id)sender{
    if ([self checkBothSourceDestinationChoosen]) {
        
        [self performSegueWithIdentifier:kSegueIdentifier_searchRideToSearchResults
                                  sender:nil];
    }
}

- (BOOL)checkBothSourceDestinationChoosen {
    if (_searchObject.sourcePlace == nil) {
        [self displayFailureMessage:@"Choose a source location."];
        return NO;
    }
    if (_searchObject.destinationPlace == nil) {
        [self displayFailureMessage:@"Choose a destination location."];
        return NO;
    }
    if ([_searchObject.sourcePlace isEqual:_searchObject.destinationPlace]) {
        [self displayFailureMessage:@"Source and destination locations can't be same."];
        return NO;
    }
    
    return YES;
}

#pragma mark - data picker methods

- (void)showDatePicker {
    [self removePicker];
    [self.datePicker setFrame:CGRectMake(0,
                                         self.view.frame.size.height - 260,
                                         self.view.frame.size.width,
                                         260)];
    
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)
    [[UIApplication sharedApplication] delegate];
    
    [appDelegate.rootViewController.view addSubview:self.datePicker];
}

- (void)removePicker {
    [self.datePicker removeFromSuperview];
}

- (void)datePickerDoneButtonTapped:(id)date {
    [self setDate:date];
    [self removePicker];
}

- (void)setDate:(id)date {
    _searchObject.date = date;
    NSString *dateString = [NSDate display_dateStringForSearchDate:date];
    [_dateLabel setText:dateString];
}

#pragma mark location selectors

- (void)showLocationSelectorControllerForType:(GTUserType)userType {
    [self performSegueWithIdentifier:kSegueIdentifier_searchRideTosearchLocation
                              sender:nil];
}

- (void)fromLocationTouched:(id)sender {
    _currentSearchType = SourceSearch;
    [self performSegueWithIdentifier:kSegueIdentifier_searchRideTosearchLocation
                              sender:nil];
}

- (void)toLocationTouched:(id)sender {
    _currentSearchType = DestinationSearch;
    [self performSegueWithIdentifier:kSegueIdentifier_searchRideTosearchLocation
                              sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSegueIdentifier_searchRideTosearchLocation]) {
        UINavigationController *navigationController = segue.destinationViewController;
        GTSearchGooglePlaceController *searchViewController = [navigationController.viewControllers objectAtIndex:0];
        
        searchViewController.delegate = self;
    }else if ([segue.identifier isEqualToString:kSegueIdentifier_searchRideToSearchResults]){
        GTSearchResultsViewController *searchResultsController =segue.destinationViewController;
        [searchResultsController setSearchObject:self.searchObject];
        [self logAnalyticsForRideSearchedBeforeDaysFromDate:self.searchObject.date];
    }
}

#pragma mark - search location controller delegates

- (void)selectedPlace:(Place *)place {
    if (_currentSearchType == SourceSearch) {
        _searchObject.sourcePlace = place;
    }else{
        _searchObject.destinationPlace = place;
    }
    [self reloadData];
}

#pragma mark - Analytics

- (void)logAnalyticsForRideSearchedBeforeDaysFromDate:(NSDate *)date {
    NSInteger days = [[NSDate date] differenceInDaysToDate:date];
    [[GTAnalyticsManager sharedInstance] logSearchedRideBeforeDays:days];
}

@end
