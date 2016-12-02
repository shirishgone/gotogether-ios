//
//  GTAddViewController.m
//  goTogether
//
//  Created by shirish on 13/08/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTAddViewController.h"
#import "TADateTimePicker.h"
#import "TALocationManager.h"
#import "TAGoogleAPIManager.h"
#import "GTSearchGooglePlaceController.h"
#import "GTAddAdvancedViewController.h"
#import "UIImage+TAExtensions.h"
#import "UIView+mm_ImageAdditions.h"
#import "UIToolbar+GTExtensions.h"
#import "GTPlacesManager.h"
#import "GTAddVehicleViewController.h"
#import "GTPhoneNumberVerificationController.h"

#define kAlertMessage_posting @"Posting ride..."
#define kAlertMessage_postingSucceded @"Ride posted."
#define kAlertMessage_cancelEvent @"Cancelling ride..."
#define kAlertMessage_postingFailed @"Posting your ride has failed."

#define kAlertMessage_allDetails @"Please fill all details before posting your ride."
#define kAlertMessage_destinationUnSelected @"Please choose your destination location."
#define kAlertMessage_sourceUnSelected  @"Please choose your start location."
#define kAlertMessage_sourceAndDestinationSame  @"Start and destination locations can't be same."

@interface GTAddViewController ()
<TASearchLocationControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *fromLocationLabel;
@property (strong, nonatomic) IBOutlet UILabel *toLocationLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIButton *addButton;

@property (strong, nonatomic) IBOutlet UILabel *vehicleDetailLabel;
@property (nonatomic, weak) IBOutlet UILabel *seatCountLabel;
@property (nonatomic, weak) IBOutlet UIStepper *seatsStepper;

@property (nonatomic, weak) IBOutlet UILabel *currencyCodeLabel;
@property (nonatomic, weak) IBOutlet UITextField *costTextField;

@property (nonatomic, assign) float rideLength;
@property (nonatomic, assign) BOOL didAskForAddingVehicle;

@property (nonatomic, strong) TADateTimePicker *datePicker;
@property (readwrite, nonatomic) GTSearchLocationType currentSearchType;
@property (nonatomic, strong) Vehicle *vehicle;

@property (nonatomic, strong) Place *sourcePlace;
@property (nonatomic, strong) Place *destinationPlace;


- (IBAction)postRideButtonTouched:(id)sender;
- (IBAction)stepperValueChanged:(id)sender;

@end

@implementation GTAddViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    if (self.eventMode == eventMode_editEvent) {
        [self initialiseForEditMode];
    }else{
        [self initialiseNewEvent];
    }
    [self initialiseUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self trackScreenName:@"AddRide"];
}

- (void)initialiseUI {
    [self initializeVehicleDetails];
    [self initialiseDatePicker];
    [self initialiseSeatStepper];
    [self setCurrencyCode];
    [self setupDoneButtonBarForPriceKeyboard];
    [UIButton addBorderToButton:self.addButton];
}

- (void)setEventMode:(GTEventMode)eventMode{
    _eventMode = eventMode;
}

#pragma mark - Storyboard Segue methods

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:kSegueIdentifier_addToLocationSelector]) {
        UINavigationController *navigationController = segue.destinationViewController;
        GTSearchGooglePlaceController *searchViewController = [navigationController.viewControllers objectAtIndex:0];
        searchViewController.delegate = self;
    }
}

#pragma mark - initialisation methods
- (void)initialiseForEditMode {
    self.title = @"Edit";
    [self.addButton setTitle:@"Update" forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_trash"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(deleteRideTouched:)
     ];

    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTouched:)];

    [self reloadData];
}

- (void)initialiseNewEvent {

    User *currentUser = [User currentUser];
    self.event = [[Event alloc] initWithEntity:[Event entityDescription]
                insertIntoManagedObjectContext:nil];
    
    [self.event setUserId:currentUser.userId];
    [self.event setUserName:currentUser.name];
    [self.event setUserType:kUserType_owner];
    [self.event setEventType:kEventType_everybody];
    [self.event setAvailableSeatsValue:1];
    [self.event setCreatedDate:[NSDate date]];
    [self.event setDateTime:[NSDate date]];
//    [self setSourceAsCurrentLocation];
    [self reloadData];
}

- (void)resetAllFields {
    self.event = nil;
    [self initialiseNewEvent];
//    [self.tableView layoutIfNeeded];
}

- (void)initializeVehicleDetails {
    _vehicle = [[User currentUser] vehicle];
    [self updateVehicle:_vehicle];
}

- (void)updateVehicle:(Vehicle *)vehicle {
    NSString *vehicleDetailString;
    if (vehicle!= nil) {
        vehicleDetailString = [NSString  stringWithFormat:@"%@ %@",[vehicle make],[vehicle model]];
    }else {
        vehicleDetailString = @"Add vehicle details";
    }
    [self.vehicleDetailLabel setText:vehicleDetailString];
}

- (void)initialiseSeatStepper {
    [self.seatsStepper setMinimumValue:kSeatsAllowed_min];
    [self.seatsStepper setMaximumValue:kSeatsAllowed_max];
    [self.seatsStepper setValue:1.0];
    [self updateSeatCountLabel];
}

- (void)setCurrencyCode {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [self.currencyCodeLabel setText:[numberFormatter currencySymbol]];
}

- (void)initialiseDatePicker {
    if (_datePicker == nil) {
        _datePicker = [[TADateTimePicker alloc]
                       initWithFrame:CGRectMake(0,
                                                self.view.frame.size.height - kDatePickerHeight,
                                                self.view.frame.size.width,
                                                kDatePickerHeight)];
        [_datePicker setMode:UIDatePickerModeDateAndTime];
        [_datePicker addTargetForDoneButton:self action:@selector(datePickerDoneButtonTapped:)];
    }
}

- (void)setSourceAsCurrentLocation {
    TALocationManager *locationManager = [TALocationManager sharedInstance];
    TAGoogleAPIManager *googleAPIManager = [TAGoogleAPIManager sharedInstance];
    [self displayActivityIndicatorViewWithMessage:@"Fetching current location...."];
    
    [self.event setSourceLatitudeValue:locationManager.currentLocation.coordinate.latitude];
    [self.event setSourceLongitudeValue:locationManager.currentLocation.coordinate.longitude];

    [googleAPIManager
     fetchLocationNameForLatitude:locationManager.currentLocation.coordinate.latitude
     longitude:locationManager.currentLocation.coordinate.longitude
     ifSucess:^(Place *place) {

         [self hideStatusMessage];
         self.sourcePlace = place;
         [self.event setSourceName:place.displayName];
         [self reloadData];
         
     } ifFailure:^(NSError *error) {;
         [self hideStatusMessage];
     }];
}

- (void)setupDoneButtonBarForPriceKeyboard {
    UIToolbar *toolBar =
    [UIToolbar GTToolBarWithDoneButtonWithDelegate:self andSelector:@selector(doneWithNumberPad)];
    
    _costTextField.inputAccessoryView = toolBar;
}

- (void)doneWithNumberPad {
    [_costTextField resignFirstResponder];
    NSString *costString = _costTextField.text;
    self.event.seatPriceValue = [costString doubleValue];
}

- (void)reloadData {
    if (self.event.sourceName != nil) {
        [_fromLocationLabel setText:self.event.sourceName];
    }else {
        [_fromLocationLabel setText:@"going from?"];
    }

    if (self.event.destinationName != nil) {
        [_toLocationLabel setText:self.event.destinationName];
    }else {
        [_toLocationLabel setText:@"going to?"];
    }
    
    if (self.event.dateTime != nil) {
        NSString *dateString = [NSDate display_dataStringForDate:self.event.dateTime];
        [_dateLabel setText:dateString];
    }
    
    [self updateSeatCountLabel];
    
    if (self.event.seatPriceValue != 0 && self.event.seatPrice != nil) {
        [self.costTextField setText:[self.event.seatPrice stringValue]];
    }else{
        [self.costTextField setText:@"0"];
    }
}

#pragma mark - action handler methods

- (IBAction)stepperValueChanged:(id)sender{
    [self.event setAvailableSeatsValue:(int)self.seatsStepper.value];
    [self updateSeatCountLabel];
}

- (void)updateSeatCountLabel {
    if (self.event.availableSeatsValue == 1) {
        [_seatCountLabel setText:[NSString stringWithFormat:@"%d seat",self.event.availableSeatsValue]];
    }else{
        [_seatCountLabel setText:[NSString stringWithFormat:@"%d seats",self.event.availableSeatsValue]];
    }
}

- (void)deleteRideTouched:(id)sender{
    
    NSString *messageString = @"Cancelling this ride will send notifications to your travellers and delete it from the system permenanty. Do you want to continue";
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Cancel ride"
                                                     andMessage:messageString];
    [alertView addButtonWithTitle:@"Continue"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              [self cancelEvent];
    }];
    
    [alertView addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeDestructive handler:nil];
    [alertView setTransitionStyle:SIAlertViewTransitionStyleDropDown];
    [alertView setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
    [alertView show];
}

#pragma mark - Post Button Hnadler
- (void)updateEvent:(id)sender {
    if ([self checkBothSourceDestinationChoosenAndShowAlert]) {
        
        [self displayActivityIndicatorViewWithMessage:@"Updating..."];
        
        self.sourcePlace = [[GTPlacesManager sharedInstance] temporaryPlace];
        self.sourcePlace.placeName = self.event.sourceName;
        
        self.destinationPlace = [[GTPlacesManager sharedInstance] temporaryPlace];
        self.destinationPlace.placeName = self.event.destinationName;
        
        [Place cleanupPlaceNamesForEvent:self.event
                             sourcePlace:self.sourcePlace
                        destinationPlace:self.destinationPlace];
        
        [self logAnalyticsForRideCreated:self.event];
        [Event
         editEventWithDetails:self.event
         sucess:^(Event *event) {
             [self displaySucessMessage:@"Updated successfully."];
             [self dismissViewControllerAnimated:YES completion:^{
                 [self postEventUpdatedNotificationWithEvent:event];
             }];
         
         } failure:^(NSError *error) {
            [self displayFailureMessage:@"Failed to update."];
            
        }];
    }else {
        [self displayFailureMessage:kAlertMessage_destinationUnSelected];
    }
}

- (void)postEventUpdatedNotificationWithEvent:(Event *)event {
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:event
                 forKey:kNotificaionObject_updatedEvent];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNotificaionType_eventUpdated
     object:nil
     userInfo:userInfo];
}

- (void)cancelEvent {
    [self displayActivityIndicatorViewWithMessage:kAlertMessage_cancelEvent];
    [Event
     cancelEventWithDetails:self.event
     sucess:^(NSString *successMessage) {
         [self displaySucessMessage:successMessage];
         [self dismissViewControllerAnimated:YES completion:^{
             if ([self.delegate respondsToSelector:@selector(eventDeleted)]) {
                 [self.delegate eventDeleted];
             }
         }];
     } failure:^(NSError *error) {
         [self displayFailureMessage:@"Failed to cancel. Try again!"];
     }];
}

- (void)presentPhoneVerificationView {
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)
    [[UIApplication sharedApplication] delegate];
    
    [appDelegate.rootViewController presentPhoneVerificationView];
}

- (void)showPhoneVerificationAlert {
    NSString *message = @"Please verify your phone, before posting your ride.";
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:message];
    [alertView addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeDestructive handler:nil];
    [alertView addButtonWithTitle:@"Verify" type:SIAlertViewButtonTypeDefault handler:^
     (SIAlertView *alertView) {
         [self presentPhoneVerificationView];
     }];
    
    [alertView setTransitionStyle:SIAlertViewTransitionStyleDropDown];
    [alertView setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
    [alertView show];
    return;
}

- (IBAction)postRideButtonTouched:(id)sender {

    if (self.eventMode == eventMode_editEvent) {
        [self updateEvent:sender];
        return;
    }

    if ([self checkIfVehicleAdded] == NO) {
        [self showErrorMessage:@"Please add your vehicle details in your profile, before posting your ride."];
        return;
    }
    
    if ([self checkBothSourceDestinationChoosenAndShowAlert]) {

        if ([User isPhoneVerified] == NO) {
            [self showPhoneVerificationAlert];
            return;
        }

        User *currentUser = [User currentUser];
        Vehicle *userVehicle = [currentUser vehicle];
        NSString *dateString = [NSDate display_onlyDateStringFromDate:[self.event dateTime]];
        NSString *vehicleString = [NSString  stringWithFormat:@"%@ %@", userVehicle.make, userVehicle.model];
        NSString *title = NSLocalizedString(@"postride_title", nil);
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"postride_message", nil)
                             ,self.event.sourceName,
                             self.event.destinationName,
                             vehicleString,
                             dateString,
                             [self.event.availableSeats integerValue]
                             ];
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
        [alertView addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeDestructive handler:nil];
        [alertView addButtonWithTitle:@"Confirm" type:SIAlertViewButtonTypeDefault handler:^
         (SIAlertView *alertView) {
             [self postRide];
         }];
        
        [alertView setTransitionStyle:SIAlertViewTransitionStyleDropDown];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
        [alertView show];
        
    }else {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:kAlertMessage_allDetails];
        [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDestructive handler:nil];
        [alertView setTransitionStyle:SIAlertViewTransitionStyleDropDown];
        [alertView setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
        [alertView show];
    }
}

- (void)showErrorMessage:(NSString *)message {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:message];
    [alertView addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
    [alertView setTransitionStyle:SIAlertViewTransitionStyleDropDown];
    [alertView setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
    [alertView show];

}

- (void)postRide {
    [self displayActivityIndicatorViewWithMessage:kAlertMessage_posting];
    [Place cleanupPlaceNamesForEvent:self.event
                         sourcePlace:self.sourcePlace
                    destinationPlace:self.destinationPlace];
    
    [self logAnalyticsForRideCreated:self.event];
    [Event
     createEventWithDetails:self.event
     sucess:^(Event *event) {
         [self displaySucessMessage:kAlertMessage_postingSucceded];
         
         self.event = event;
         [self postEventCreatedNotificationAndShowRideDetails:event];

         [self resetAllFields];
         [self reloadData];
         
     } failure:^(NSError *error) {
         [self displayFailureMessage:kAlertMessage_postingFailed];
     }];
}

- (void)postEventCreatedNotificationAndShowRideDetails:(Event *)event {
    // POST Notification
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        [[NSNotificationCenter defaultCenter]
         postNotificationName:kNotificaionType_newEventCreated
         object:nil];
        
        goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.rootViewController showCreatedRide:event];
    });
}

#pragma mark - Action Handlers

- (void)cancelButtonTouched:(id)sender {
    [self.event discardUnSavedChanges];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)segmentValueChanged:(id)sender{
    UISegmentedControl *segmentControl = sender;
    if (segmentControl.selectedSegmentIndex == 0) {
        [self.event setUserType:kUserType_owner];
    }else{
        [self.event setUserType:kUserType_passenger];
    }
}

- (BOOL)checkBothSourceDestinationChoosenAndShowAlert {
    if (self.event.sourceName == nil) {
        [self displayFailureMessage:kAlertMessage_sourceUnSelected];
        return NO;
    }
    if (self.event.destinationName == nil){
        [self displayFailureMessage:kAlertMessage_destinationUnSelected];
        return NO;
    }
    if (self.event.destinationLatitude == self.event.sourceLatitude &&
        self.event.destinationLongitude == self.event.sourceLongitude)
    {
        [self displayFailureMessage:kAlertMessage_sourceAndDestinationSame];
        return NO;
    }
    
    return YES;
}

- (BOOL)checkBothSourceDestinationChoosen {
    if (self.event.sourceName == nil) {
        return NO;
    }
    if (self.event.destinationName == nil){
        return NO;
    }
    if (self.event.destinationLatitude == self.event.sourceLatitude &&
        self.event.destinationLongitude == self.event.sourceLongitude)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)checkIfVehicleAdded {
    User *currentUser = [User currentUser];
    if(currentUser.vehicle == nil){
        return NO;
    }else {
        return YES;
    }
}

#pragma mark - textfield delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect tableFrame = self.tableView.frame;
    [self.tableView setFrame:CGRectMake(tableFrame.origin.x,
                                        tableFrame.origin.y,
                                        tableFrame.size.width,
                                        tableFrame.size.height - kKeyboardHeight - kToolbarHeight)];
    
    textField.text = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    CGRect tableFrame = self.tableView.frame;
    [self.tableView setFrame:CGRectMake(tableFrame.origin.x,
                                        tableFrame.origin.y,
                                        tableFrame.size.width,
                                        tableFrame.size.height + kKeyboardHeight + kToolbarHeight)];
    
}

#pragma mark - data picker methods
- (void)showDatePicker {
    [self removePicker];
    [self.datePicker setFrame:CGRectMake(0,
                                         self.view.frame.size.height - kDatePickerHeight,
                                         self.view.frame.size.width,
                                         kDatePickerHeight)];

    if (self.eventMode == eventMode_editEvent) {
            [self.view addSubview:self.datePicker];
    }else {
        goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.rootViewController.view addSubview:self.datePicker];
    }
}

- (void)removePicker {
    [self.datePicker removeFromSuperview];
}

- (void)datePickerDoneButtonTapped:(id)date{
    [self.event setDateTime:date];
    [self reloadData];
    [self removePicker];
}

#pragma mark location selectors

- (void)fromLocationTouched:(id)sender {
    _currentSearchType = SourceSearch;
    [self performSegueWithIdentifier:kSegueIdentifier_addToLocationSelector
                              sender:nil];
}

- (void)toLocationTouched:(id)sender {
    _currentSearchType = DestinationSearch;
    [self performSegueWithIdentifier:kSegueIdentifier_addToLocationSelector
                              sender:nil];
}

- (void)dateTouched:(id)sender{
    [self showDatePicker];
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
        }else if (indexPath.row == 1){
            [self fromLocationTouched:nil];
        }else{
            [self dateTouched:nil];
        }
    }else if (indexPath.section == 1 && indexPath.row == 1){
        [self.costTextField becomeFirstResponder];
    }else if (indexPath.section == 2 && indexPath.row == 0){
        if (_vehicle == nil) {
            [self showAddVehicle];
        }
    }
}

#pragma mark - search location controller delegates
- (void)selectedPlace:(Place *)place {
    if (_currentSearchType == SourceSearch) {
        self.sourcePlace = place;
        [self.event setSourceName:place.displayName];
        [self.event setSourceLatitude:place.latitude];
        [self.event setSourceLongitude:place.longitude];
    }else{
        self.destinationPlace = place;
        [self.event setDestinationName:place.displayName];
        [self.event setDestinationLatitude:place.latitude];
        [self.event setDestinationLongitude:place.longitude];
    }

    if([self checkBothSourceDestinationChoosen]){
        self.rideLength = [self distanceBetweenSourceAndDestinationForEvent:self.event];
        
        if (self.rideLength > 0 && [self isIndia]) {
            [self setSuggestivePrice];
        }
        double distanceInKm = self.rideLength/kMetersToKiloMeters;
        if (distanceInKm < 50.0) {
            [self showDistanceLimitAlert];
            [self resetAllFields];
        }
    }
    [self reloadData];
}

- (void)showDistanceLimitAlert {
    NSString *messageString = @"gotogether currently supports rides which are more than 50kms. We believe that we can serve you better for long distance ride-sharing.";
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"gotogether - Distance Limit"
                                                     andMessage:messageString];
    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {

                          }];
    [alertView setTransitionStyle:SIAlertViewTransitionStyleDropDown];
    [alertView setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
    [alertView show];
}

- (double)distanceBetweenSourceAndDestinationForEvent:(Event *)event {

    CLLocationCoordinate2D sourceCoordinate =
    CLLocationCoordinate2DMake(event.sourceLatitudeValue
                               ,event.sourceLongitudeValue
                               );
    
    CLLocationCoordinate2D destinationCoordinate =
    CLLocationCoordinate2DMake(event.destinationLatitudeValue
                               ,event.destinationLongitudeValue
                               );
    
    double rideLength = 0.0;
    if (sourceCoordinate.latitude !=0 && sourceCoordinate.longitude !=0 &&
        destinationCoordinate.latitude !=0 && destinationCoordinate.longitude!=0) {
        
        rideLength = [TALocationManager distanceBetweenCoordinate:sourceCoordinate
                                              andSecondCoordinate:destinationCoordinate
         ];
    }
    
    return rideLength;
}

- (void)setSuggestivePrice {
    CLLocationCoordinate2D sourceCoordinate =
    CLLocationCoordinate2DMake(self.event.sourceLatitudeValue
                               ,self.event.sourceLongitudeValue
                               );
    
    CLLocationCoordinate2D destinationCoordinate =
    CLLocationCoordinate2DMake(self.event.destinationLatitudeValue
                               ,self.event.destinationLongitudeValue
                               );
    
    if (sourceCoordinate.latitude !=0 && sourceCoordinate.longitude !=0 &&
        destinationCoordinate.latitude !=0 && destinationCoordinate.longitude!=0) {
        self.rideLength =
        [TALocationManager distanceBetweenCoordinate:sourceCoordinate
                                 andSecondCoordinate:destinationCoordinate
         ];

        double cost = [TALocationManager costPerDistance:self.rideLength];
        [self.event setSeatPriceValue:cost];
        [self updateSeatCostLabel];
    }
}

- (BOOL)isIndia {
    //Auto fill cost only for India
    NSLocale * locale = [NSLocale currentLocale];
    NSString * localeIdentifier = [locale objectForKey:NSLocaleIdentifier];
    if ([localeIdentifier isEqualToString:@"en_IN"]) {
        return YES;
    }else {
        return NO;
    }
}

- (void)updateSeatCostLabel {
    if (self.event.seatPriceValue > 0.0) {
        [self.costTextField setText:[NSString stringWithFormat:@"%.0f",self.event.seatPriceValue]];
    }
}

- (void)showAddVehicle {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier bundle:[NSBundle mainBundle]];
    GTAddVehicleViewController *addVehicleViewController = [storyBoard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_addVehicle];
    UINavigationController *addVehicleNavController = [[UINavigationController alloc] initWithRootViewController:addVehicleViewController];
    [self presentViewController:addVehicleNavController animated:YES completion:nil];
}

- (void)vehicleDetailsAddedSuccessfully {
    self.vehicle = [[User currentUser] vehicle];
    [self updateVehicle:_vehicle];
}

#pragma mark - Analytics

- (void)logAnalyticsForRideCreated:(Event *)event {
    [[GTAnalyticsManager sharedInstance] logRideCreatedWithDistance:self.rideLength];
    [[GTAnalyticsManager sharedInstance] logNumberOfSeatsOffered:self.event.availableSeatsValue];
}


@end
