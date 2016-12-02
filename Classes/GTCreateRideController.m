//
//  GTCreateRideController.m
//  goTogether
//
//  Created by shirish on 27/03/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "GTCreateRideController.h"
#import "TADateTimePicker.h"
#import "goTogetherAppDelegate.h"
#import "TAFacebookManager.h"
#import "GTGoogleMapsRouteViewController.h"
#import "GTSearchGooglePlaceController.h"
#import "Place.h"
#import "TARoute.h"
#import "TALocationManager.h"
#import "TAGoogleAPIManager.h"
#import "GTTableCell_CreateRide_SeatCountAndCost.h"
#import "GTTableCell_CreateRide_rideVisiblilty.h"
#import "GTTableCell_CreateRide_DrivingOrNeedARide.h"
#import "GTTableCell_CreateRide_IconKeyValue.h"
#import "GTFlurryManager.h"
#import "GTFlurryConstants.h"
#import "GTTableCell_CreateRide_facebookShare.h"
#import "GTFriendsListViewController.h"

typedef enum {
    cellType_rideType,
    cellType_fromLocation,
    cellType_toLocation,
    cellType_date,
    cellType_recurringEvent,
    cellType_daySelection,
    cellType_route,
    cellType_seatCost,
    cellType_rideVisibility,
    cellType_facebook,
    cellType_travellingWith
}GTCreateRide_cellType;

#define kCellHeight_rideType     40.0f

#define kCellHeight_fromLocation 40.0f
#define kCellHeight_toLocation   40.0f
#define kCellHeight_date         40.0f

#define kCellHeight_daySelection 40.0f
#define kCellHeight_route        40.0f
#define kCellHeight_seatCost     60.0f

#define kCellHeight_rideVisibility    40.0f
#define kCellHeight_travellingWith    40.0f

#define kCellDataDict_key   @"key"
#define kCellDataDict_value @"value"
#define kCellDataDict_image @"image"


@interface GTCreateRideController ()
<TASearchLocationControllerDelegate,
TAGoogleMapsRouteSelectorDelegate,
UIActionSheetDelegate,
GTTableCell_CreateRide_DrivingOrNeedARideDelegate,
GTTableCell_CreateRide_ShareWithDelegate,
GTFriendsSelectedDelegate,
GTTableCell_CreateRide_SeatCountAndCost_Delegate>

@property (nonatomic, strong) NSArray *imDrivingCellArray;
@property (nonatomic, strong) NSArray *iNeedRideCellArray;

@property (nonatomic) GTUserType selectedUserType;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet RCSwitchClone *facebookSwitch;

@property (nonatomic, strong) NSMutableDictionary *cellDataDictionary;
@property (nonatomic, strong) TADateTimePicker *datePicker;
@property (readwrite, nonatomic) GTSearchLocationType currentSearchType;
@property (nonatomic, strong) NSArray *fetchedRoutes;
@property (nonatomic, strong) NSArray *taggedFriends;
@property (nonatomic) GTShareWith selectedShareWith;

- (void)cancelButtonTouched:(id)sender;
- (void)createButtonTouched:(id)sender;

@end

@implementation GTCreateRideController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initialiseDatePicker];

    switch(self.eventMode) {
        case eventMode_createEvent:
            [self initializeForCreateMode];
            break;
        case eventMode_editEvent:
            [self initializeForEditMode];
            break;
        default:
            break;
    }    
    [self setCancelButton];
    [self setCreateButton];
    [self.facebookSwitch setSwitchType:switchType_facebook];
}
- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setCancelButton{
    UIButton *button = [UIButton nav_closeButton];
    [button addTarget:self
               action:@selector(cancelButtonTouched:)
     forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = cancelBarButtonItem;
}

- (void)setCreateButton{
    
    UIButton *button = [UIButton nav_doneButton];
    [button addTarget:self
               action:@selector(createButtonTouched:)
     forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *createBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = createBarButtonItem;
}

- (void)initializeKeyboardDelegates{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardShown)
     name:UIKeyboardDidShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardHidden)
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (void)initializeForCreateMode{

    self.title =  @"Add";
    self.event = [Event MR_createEntity];
    [self setSourceAsCurrentLocation];
    [self setSelectedUserType:userType_passenger];
    [self setSelectedShareWith:shareWith_everybody];
    [self.event setDateTime:[NSDate date]];
    [self.event setAvailableSeatsValue:1];
    [self initializeCellData];
    [self rideTypeSelected:userType_passenger];
}

- (void)initializeForEditMode{
    self.title =  @"Update";
    self.navigationItem.rightBarButtonItem.title = @"Update";
    
    [self initializeCellData];
    [self setSourceFromExistingEvent];
    [self setDestinationFromExistingEvent];
    [self setCostFromExistingEvent];
    
    if ([self.event.userType isEqualToString:@"owner"]) {
        self.selectedUserType = userType_driving;
    }else{
        self.selectedUserType = userType_passenger;
    }
}

- (void)initialiseDatePicker{
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

- (void)initializeCellData{

    self.imDrivingCellArray =
    @[
      // SECTION~0
      @[[NSNumber numberWithInteger:cellType_toLocation],
        [NSNumber numberWithInteger:cellType_fromLocation],
        [NSNumber numberWithInteger:cellType_date]],

      // SECTION~1
      @[[NSNumber numberWithInteger:cellType_route]],

      // SECTION~3
      @[[NSNumber numberWithInteger:cellType_rideType]],

      // SECTION~5
      @[[NSNumber numberWithInteger:cellType_seatCost]],

      // SECTION~4
      @[[NSNumber numberWithInteger:cellType_rideVisibility]],
      
      // SECTION~2
      @[[NSNumber numberWithInteger:cellType_travellingWith]],

      ];
    
    self.iNeedRideCellArray =
    @[
      // SECTION~0
      @[[NSNumber numberWithInteger:cellType_toLocation],
        [NSNumber numberWithInteger:cellType_fromLocation],
        [NSNumber numberWithInteger:cellType_date]],

      // SECTION~1
      @[[NSNumber numberWithInteger:cellType_route]],

      // SECTION~3
      @[[NSNumber numberWithInteger:cellType_rideType]],

      // SECTION~5
      @[[NSNumber numberWithInteger:cellType_seatCost]],

      // SECTION~4
      @[[NSNumber numberWithInteger:cellType_rideVisibility]],
    
      ];
    
    self.cellDataDictionary = [NSMutableDictionary dictionary];
    NSMutableDictionary *fromLocationDictionary= [NSMutableDictionary dictionary];
    [fromLocationDictionary setValue:[UIImage imageNamed:@"ico_location.png"] forKey:kCellDataDict_image];
    [fromLocationDictionary setValue:@"From" forKey:kCellDataDict_key];
    [fromLocationDictionary setValue:@"going From?" forKey:kCellDataDict_value];
    [_cellDataDictionary setValue:fromLocationDictionary
                           forKey:[self stringValueForCellType:cellType_fromLocation]];
    
    
    NSMutableDictionary *toLocationDictionary= [NSMutableDictionary dictionary];
    [toLocationDictionary setValue:[UIImage imageNamed:@"ico_location.png"]forKey:kCellDataDict_image];
    [toLocationDictionary setValue:@"To"forKey:kCellDataDict_key];
    [toLocationDictionary setValue:@"going To?"forKey:kCellDataDict_value];
    [_cellDataDictionary setValue:toLocationDictionary
                           forKey:[self stringValueForCellType:cellType_toLocation]];
    
    
    NSMutableDictionary *datetimeDictionary= [NSMutableDictionary dictionary];
    [datetimeDictionary setValue:[UIImage imageNamed:@"ico_time.png"]forKey:kCellDataDict_image];
    [datetimeDictionary setValue:@"When"forKey:kCellDataDict_key];
    [datetimeDictionary setValue:[NSDate display_dataStringForDate:_event.dateTime] forKey:kCellDataDict_value];
    [_cellDataDictionary setValue:datetimeDictionary
                           forKey:[self stringValueForCellType:cellType_date]];
    
    NSMutableDictionary *routeDictionary= [NSMutableDictionary dictionary];
    [routeDictionary setValue:@"Route"forKey:kCellDataDict_key];
    [routeDictionary setValue:@"Select Route"forKey:kCellDataDict_value];
    [routeDictionary setValue:[UIImage imageNamed:@"ico_route.png"]forKey:kCellDataDict_image];
    [_cellDataDictionary setValue:routeDictionary
                           forKey:[self stringValueForCellType:cellType_route]];
    
    
    NSMutableDictionary *travellingWithDictionary= [NSMutableDictionary dictionary];
    [travellingWithDictionary setValue:@"Travelling With"forKey:kCellDataDict_key];
    [travellingWithDictionary setValue:@"alone?"forKey:kCellDataDict_value];
    [travellingWithDictionary setValue:[UIImage imageNamed:@"ico_visibility.png"]
                                forKey:kCellDataDict_image];
    [_cellDataDictionary setValue:travellingWithDictionary
                           forKey:[self stringValueForCellType:cellType_travellingWith]];

}

- (void) setSourceFromExistingEvent{
    
    NSDictionary *fromDictionary = [_cellDataDictionary objectForKey:[self stringValueForCellType:cellType_fromLocation]];
    [fromDictionary setValue:self.event.sourceName forKey:kCellDataDict_value];
    [_cellDataDictionary setValue:fromDictionary forKey:[self stringValueForCellType:cellType_fromLocation]];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self indexPathForCellType:cellType_fromLocation]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) setDestinationFromExistingEvent{
    
    NSDictionary *toDictionary = [_cellDataDictionary objectForKey:[self stringValueForCellType:cellType_toLocation]];
    [toDictionary setValue:self.event.destinationName forKey:kCellDataDict_value];
    [_cellDataDictionary setValue:toDictionary forKey:[self stringValueForCellType:cellType_toLocation]];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self indexPathForCellType:cellType_toLocation]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) setCostFromExistingEvent{
    
    GTTableCell_CreateRide_SeatCountAndCost *cell = (GTTableCell_CreateRide_SeatCountAndCost *)
    [self.tableView cellForRowAtIndexPath:[self indexPathForCellType:cellType_seatCost]];
    [cell setCost:[self.event.seatPrice doubleValue]];
    [cell setSeatCount:[self.event.availableSeats integerValue]];
}

//- (void)setRouteFromExistingEvent{
//    [self.event setRoutePoints:[TARoute stringFromRoute:route]];
//    NSDictionary *routeDictionary = [_cellDataDictionary objectForKey:[self stringValueForCellType:cellType_route]];
//    [routeDictionary setValue:[NSString stringWithFormat:@"Route %d Selected",index] forKey:kCellDataDict_value];
//    [_cellDataDictionary setValue:routeDictionary forKey:[self stringValueForCellType:cellType_route]];
//    
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self indexPathForCellType:cellType_route]]
//                          withRowAnimation:UITableViewRowAnimationAutomatic];
//}

- (void)setSourceAsCurrentLocation{
    
    TALocationManager *locationManager = [TALocationManager sharedInstance];
    TAGoogleAPIManager *googleAPIManager = [TAGoogleAPIManager sharedInstance];
    [self displayActivityIndicatorViewWithMessage:@"Fetching Current Location...."];
    [googleAPIManager
     fetchLocationNameForLatitude:locationManager.currentLocation.coordinate.latitude
     longitude:locationManager.currentLocation.coordinate.longitude
     ifSucess:^(NSString *name) {
         
         [self hideStatusMessage];
         [_event setSourceName:name];
         [_event setSourceLatitudeValue:locationManager.currentLocation.coordinate.latitude];
         [_event setSourceLongitudeValue:locationManager.currentLocation.coordinate.longitude];
         
         NSDictionary *fromDictionary = [_cellDataDictionary objectForKey:[self stringValueForCellType:cellType_fromLocation]];
         [fromDictionary setValue:name forKey:kCellDataDict_value];
         [_cellDataDictionary setValue:fromDictionary forKey:[self stringValueForCellType:cellType_fromLocation]];
         [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self indexPathForCellType:cellType_fromLocation]]
                               withRowAnimation:UITableViewRowAnimationAutomatic];
     } ifFailure:^(NSError *error) {;
         [self hideStatusMessage];
     }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:kSegueIdentifier_createEventToRouteMap]) {
        
        Place *sourcePlace = [self placeForLatitude:[_event.sourceLatitude doubleValue]
                                          longitude:[_event.sourceLongitude doubleValue]
                                               name:_event.sourceName
                              ];
        Place *destinationPlace  = [self placeForLatitude:[_event.destinationLatitude doubleValue]
                                                longitude:[_event.destinationLongitude doubleValue]
                                                     name:_event.destinationName];

        GTGoogleMapsRouteViewController *routeViewController = segue.destinationViewController;
        if (self.fetchedRoutes !=nil) {
            [routeViewController showRouteSelectionForRoutes:self.fetchedRoutes
                                                      source:sourcePlace
                                              andDestination:destinationPlace];
        }else{            
            [routeViewController showRouteSelectionFromSource:sourcePlace
                                               andDestination:destinationPlace];
            
        }
        [routeViewController setDelegate:self];
        [routeViewController setMode:TAGoogleMapsOpenMode_routeSelection];
        
    } else if ([segue.identifier isEqualToString:kSegueIdentifier_createEventToSearchLocation]) {
        
        GTSearchGooglePlaceController *searchViewController =segue.destinationViewController;
        searchViewController.delegate = self;
    }
}

- (void)keyboardShown{
    CGRect tableFrame = self.tableView.frame;
    [self.tableView setFrame:CGRectMake(tableFrame.origin.x,
                                        tableFrame.origin.y,
                                        tableFrame.size.width,
                                        tableFrame.size.height - kKeyboardHeight)];
    [self.tableView scrollToRowAtIndexPath:[self indexPathForCellType:cellType_seatCost]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}
- (void)keyboardHidden{
    CGRect tableFrame = self.tableView.frame;
    [self.tableView setFrame:CGRectMake(tableFrame.origin.x,
                                        tableFrame.origin.y,
                                        tableFrame.size.width,
                                        tableFrame.size.height + kKeyboardHeight)];
    
}
#pragma mark - action handlers
- (void)cancelButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)fromLocationCellSelected{
    [self setCurrentSearchType:SourceSearch];
    [self performSegueWithIdentifier:kSegueIdentifier_createEventToSearchLocation sender:nil];
}

- (void)toLocationCellSelected{
    [self setCurrentSearchType:DestinationSearch];
    [self performSegueWithIdentifier:kSegueIdentifier_createEventToSearchLocation sender:nil];
}

- (void)dateCellSelected{
    [self removePicker];
    [self.view addSubview:self.datePicker];
}

- (void)routeCellSelected{

    if ([self isBothSourceAndDestinationChoosed] == YES) {
        [self performSegueWithIdentifier:kSegueIdentifier_createEventToRouteMap
                                  sender:nil];

    }else{
        [self displayFailureMessage:@"Please specify start and end locations."];
    }
}

- (void)travellingWithSelected{
    
    UIStoryboard *storyBoard =
    [UIStoryboard storyboardWithName:kStoryBoardIdentifier
                              bundle:[NSBundle mainBundle]];
    
    GTFriendsListViewController *friendsListController =
    [storyBoard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_friendsList];
    
    [friendsListController setDelegate:self];
    [friendsListController setViewMode:GTFriendsListViewModeSelection];
    if (self.taggedFriends !=nil) {
        [friendsListController setSelectedFriends:(NSMutableArray *)self.taggedFriends];
    }
    [self.navigationController pushViewController:friendsListController animated:YES];
    
}

- (BOOL)isBothSourceAndDestinationChoosed{

    if (self.event.sourceLatitudeValue == 0.0 ||
        self.event.sourceLongitudeValue == 0.0 ||
        self.event.destinationLatitudeValue == 0.0 ||
        self.event.destinationLongitudeValue == 0.0) {

        return NO;
    }else{
        return YES;
    }
}

- (void)createButtonTouched:(id)sender{
    if ([self isBothSourceAndDestinationChoosed] == NO) {
        [self displayFailureMessage:@"Please specify start and end locations."];
    }
    else {
        goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.netStatus != kNotReachable) {
            [self createEvent];
        }else{
            [self displayNoInternetMessage];
        }
    }
}

#pragma mark - date picker methods
- (void)showDatePicker{

    [self removePicker];
    [self.datePicker setFrame:
     CGRectMake(0,
      self.view.frame.size.height - kDatePickerHeight,
      self.view.frame.size.width,
      kDatePickerHeight)];
    
    [self.view addSubview:self.datePicker];
}

- (void)removePicker {
    [self.datePicker removeFromSuperview];
}

- (void)datePickerDoneButtonTapped:(id)date{

    [self.event setDateTime:date];
    NSString *dateString = [NSDate display_dataStringForDate:date];
    NSDictionary *dataDictionary = [_cellDataDictionary objectForKey:[self stringValueForCellType:cellType_date]];
    [dataDictionary setValue:dateString forKey:kCellDataDict_value];
    [_cellDataDictionary setValue:dataDictionary forKey:[self stringValueForCellType:cellType_date]];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self indexPathForCellType:cellType_date]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self removePicker];
}

- (NSComparisonResult)compareDateOnly:(NSDate *)otherDate {
    NSUInteger dateFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *selfComponents = [gregorianCalendar components:dateFlags
                                                            fromDate:[NSDate date]];
    NSDate *selfDateOnly = [gregorianCalendar dateFromComponents:selfComponents];
    NSDateComponents *otherCompents = [gregorianCalendar components:dateFlags
                                                           fromDate:otherDate];
    NSDate *otherDateOnly = [gregorianCalendar dateFromComponents:otherCompents];
    return [selfDateOnly compare:otherDateOnly];
}

- (void)shareWithFriendsSelected{

    _selectedShareWith = shareWith_friends;
    NSArray *indexArray =
    [NSArray arrayWithObject:[self indexPathForCellType:cellType_rideVisibility]];
    [self.tableView reloadRowsAtIndexPaths:indexArray
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)shareWithPublicSelected{
    _selectedShareWith = shareWith_everybody;
    NSArray *indexArray =
    [NSArray arrayWithObject:[self indexPathForCellType:cellType_rideVisibility]];
    [self.tableView reloadRowsAtIndexPaths:indexArray
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

- (BOOL)isSourceAndDestinationSame{
    if (_event.sourceLatitudeValue == _event.destinationLatitudeValue &&
        _event.sourceLongitudeValue == _event.destinationLongitudeValue) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - Creating Event
- (void)createEvent {
    
    if ([self isSourceAndDestinationSame] == YES) {
        [self displayFailureMessage:@"Start and End can't be same!"];
        return;
    }

    User *currentUser = [User currentUser];
    [_event setUserId:currentUser.userId];
    
    // SET USER TYPE
    if(_selectedUserType == userType_driving){
        [_event setUserType:@"owner"];
    }else if(_selectedUserType == userType_passenger){
        [_event setUserType:@"passenger"];
    }
    
    // SET EVENT TYPE
    if (_selectedShareWith == shareWith_friends) {
        [_event setEventType:kEventType_friends];
    }else{
        [_event setEventType:kEventType_everybody];
    }

    BOOL shareOnFacebook = [self.facebookSwitch isOn];
    
    if (_eventMode == eventMode_editEvent) {
        
        [self displayActivityIndicatorViewWithMessage:@"Updating..."];
        [Event
         editEventWithDetails:self.event
         sucess:^(id response) {
             [self displaySucessMessage:@"Successfully Updated!"];
             [self performSelector:@selector(dismissModalViewControllerAnimated:)
                        withObject:self
                        afterDelay:kAlertDisplayTime];
                          
             if (shareOnFacebook == YES) {
                 [self postOnFacebookWall];
             }
         } failure:^(NSError *error) {
             [self displayFailureMessage:@"Failed to Update."];
         }];
        
    }else{
       
        [self displayActivityIndicatorViewWithMessage:@"Adding..."];
        [Event
         createEventWithDetails:self.event
         sucess:^(NSString *eventId) {
             [self displaySucessMessage:@"Successfully added!"];
             [self dismissViewControllerAnimated:YES completion:nil];
             
             [[NSNotificationCenter defaultCenter]
              postNotificationName:kNotificaionType_newEventCreated
              object:nil];
             
             [self performSelector:@selector(dismissModalViewControllerAnimated:)
                        withObject:self
                        afterDelay:kAlertDisplayTime];
             
             // FLURRY
             [self flurrylogcreateRideWithDetails:self.event];
             
             [_event setEventId:eventId];
             if (shareOnFacebook == YES) {
                 [self postOnFacebookWall];
             }

        } failure:^(NSError *error) {
            [self displayFailureMessage:@"Failed to add. Try Again."];
        }];
    }
}

- (void)postOnFacebookWall{
    [[TAFacebookManager sharedInstance] postOnFacebookWall:[self facebookPostMessage]];
}

- (NSString *)facebookPostMessage{
    
    NSMutableString *message = nil;
    NSString *timeString = [NSDate display_onlyTimeStringFromDate:_event.dateTime];
    NSString *dateString = [NSDate display_onlyDateStringFromDate:_event.dateTime];
    User *currentUser = [User currentUser];

    NSMutableString *sourceName = [NSMutableString stringWithString:_event.sourceName];
    if ([sourceName length] > 20) {
        sourceName = [NSMutableString stringWithString:[sourceName substringToIndex:20]];
        [sourceName appendString:@"..."];
    }
    
    NSMutableString *destinationName = [NSMutableString stringWithString:_event.destinationName];
    if ([destinationName length] > 20) {
        destinationName = [NSMutableString stringWithString:[destinationName substringToIndex:20]];
        [destinationName appendString:@"..."];
    }

    NSMutableString *dateDisplayString;
    if ([self compareDateOnly:_event.dateTime] == NSOrderedSame) {
        dateDisplayString = [NSMutableString stringWithFormat:@"today at %@",timeString];
    }else{
        dateDisplayString = [NSMutableString stringWithFormat:@"on %@", dateString];
    }
    
    // CoTravellers adding to message if any
    NSMutableString *travellingWith = [[NSMutableString alloc] init];
    if (self.taggedFriends != nil) {
        [travellingWith appendString:@" travelling With "];
        for (User *friend in self.taggedFriends) {
            [travellingWith appendString:friend.name];
            if ([[self.taggedFriends lastObject] isEqual:friend] == NO) {
                [travellingWith appendString:@","];
            }
        }
    }else{
        [travellingWith appendString:@""];
    }

    // Final message string
    if (_event.userTypeValue == userType_driving) {
        message =
        [NSMutableString stringWithFormat:@"%@%@ is Offering a ride from %@ to %@ on %@. Join on gotogether!",
         currentUser.name,travellingWith,sourceName,destinationName,dateString];

    }else{
        message =
        [NSMutableString stringWithFormat:@"%@ is looking for a ride from %@ to %@ %@. Offer a ride on gotogether!",
         currentUser.name,sourceName,destinationName,dateDisplayString];
    }
    return message;
}


- (double)costPerDistance:(double)distance{

    double distanceInKm = distance/kMetersToKiloMeters;
    
    double cost = 0.0;
    if (distanceInKm <= 5.0) {
        cost = kCostPerKM_Slab1_LessThan5KM * distanceInKm;
    }else if (distanceInKm <= 10.0){
        cost = kCostPerKM_Slab2_LessThan10KM * distanceInKm;
    }else if (distanceInKm <= 20.0){
        cost = kCostPerKM_Slab3_LessThan20KM * distanceInKm;
    }else if (distanceInKm <= 50.0){
        cost = kCostPerKM_Slab4_LessThan50KM * distanceInKm;
    }else if (distanceInKm <= 100.0){
        cost = kCostPerKM_Slab5_LessThan100KM * distanceInKm;
    }else{
        cost = kCostPerKM_Slab6_Above100KM * distanceInKm;
    }
    
    cost = round(cost/10) *10;
    return cost;
}

#pragma mark - seatcount and seatprice delegates
- (void)priceSelected:(double)price{
    [self.event setSeatPriceValue:price];
}

- (void)numberOfSeatsSelected:(NSInteger)seatsCount{
    [self.event setAvailableSeatsValue:seatsCount];
}

#pragma mark - RouteSelectorDelegates
- (void)routeSelectedWithRoute:(TARoute *)route withIndex:(NSInteger)index{

    [self.event setRouteDistanceValue:route.distance];
    double cost = [self costPerDistance:route.distance];
    [self.event setSeatPriceValue:cost];
        
    [self.event setRoutePoints:[TARoute stringFromRoute:route]];
    NSDictionary *routeDictionary = [_cellDataDictionary objectForKey:[self stringValueForCellType:cellType_route]];
    [routeDictionary setValue:[NSString stringWithFormat:@"Route %d",index] forKey:kCellDataDict_value];
    [_cellDataDictionary setValue:routeDictionary forKey:[self stringValueForCellType:cellType_route]];
    

    NSArray *reloadArray = [NSArray arrayWithObjects:[self indexPathForCellType:cellType_route],
                            [self indexPathForCellType:cellType_seatCost],nil];
    [self.tableView reloadRowsAtIndexPaths:reloadArray
                              withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)resetRouteDictionary{

    [self.event setRoutePoints:nil];
    NSDictionary *routeDictionary = [_cellDataDictionary objectForKey:[self stringValueForCellType:cellType_route]];
    [routeDictionary setValue:@"Select Route" forKey:kCellDataDict_value];
    [_cellDataDictionary setValue:routeDictionary forKey:[self stringValueForCellType:cellType_route]];
}

#pragma mark - search location controller delegates
- (void)selectedPlace:(TAPlace *)place{
    
    TALog(@"place: %@",place);
    if (_currentSearchType == SourceSearch) {
        self.event.sourceLatitude = place.latitude;
        self.event.sourceLongitude = place.longitude;
        self.event.sourceName = place.placeName;
        self.event.seatPriceValue = 0.0;
        [self resetRouteDictionary];
        
        NSDictionary *fromDictionary = [_cellDataDictionary objectForKey:[self stringValueForCellType:cellType_fromLocation]];
        [fromDictionary setValue:place.placeName forKey:kCellDataDict_value];
        [_cellDataDictionary setValue:fromDictionary forKey:[self stringValueForCellType:cellType_fromLocation]];
        
        [self.tableView reloadData];
    }else{
        self.event.destinationLatitude = place.latitude;
        self.event.destinationLongitude = place.longitude;
        self.event.destinationName = place.placeName;
        self.event.seatPriceValue = 0.0;
        [self resetRouteDictionary];
        
        NSDictionary *toDictionary = [_cellDataDictionary objectForKey:[self stringValueForCellType:cellType_toLocation]];
        [toDictionary setValue:place.placeName forKey:kCellDataDict_value];
        [_cellDataDictionary setValue:toDictionary forKey:[self stringValueForCellType:cellType_toLocation]];
        [self.tableView reloadData];
    }

    if(self.event.destinationLatitude !=nil && self.event.destinationLongitude !=nil
       && self.event.sourceLatitude !=nil && self.event.sourceLongitude !=nil){
        
        CLLocationCoordinate2D sourceCoordinate =
        CLLocationCoordinate2DMake(self.event.sourceLatitudeValue,
                                   self.event.sourceLongitudeValue);
        
        CLLocationCoordinate2D destinationCoordinate =
        CLLocationCoordinate2DMake(self.event.destinationLatitudeValue,
                                   self.event.destinationLongitudeValue);
        [self fetchRoutesBetweenSource:sourceCoordinate
                           destination:destinationCoordinate
         ];
    }
}

- (void)fetchRoutesBetweenSource:(CLLocationCoordinate2D)sourceCoordinate
                     destination:(CLLocationCoordinate2D)destinationCoordinate{

    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.netStatus != kNotReachable) {
        [self performSelector:@selector(displayActivityIndicatorViewWithMessage:)
                   withObject:@"Fetching Available Routes ..."
                   afterDelay:0.1];
        
        [[TAGoogleAPIManager sharedInstance]
         fetchRoutesFromCoordinate:sourceCoordinate
         toCoordinate:destinationCoordinate
         ifSucess:^(NSArray *routes) {
             
             [self hideStatusMessage];

             NSInteger routesCount = [routes count];
             
             if (routesCount > 0) {
                 self.fetchedRoutes = routes;
                 
                 NSDictionary *routeDictionary = [_cellDataDictionary valueForKey:[self stringValueForCellType:cellType_route]];
                 if (routeDictionary !=nil) {
                     NSString *routeKeyString = [NSString stringWithFormat:@"%d Routes",routesCount];
                     [routeDictionary setValue:routeKeyString forKey:kCellDataDict_key];                     
                     [_cellDataDictionary setValue:routeDictionary forKey:[self stringValueForCellType:cellType_route]];
                     
                     [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self indexPathForCellType:cellType_route]]
                                           withRowAnimation:UITableViewRowAnimationAutomatic];
                     
                 }
                 
                 NSArray *routePoints = [self.fetchedRoutes objectAtIndex:0];
                 TARoute *route = [TAGoogleAPIManager routeForRoutePoints:routePoints
                                                     withSourceCoordinate:sourceCoordinate
                                                    destinationCoordinate:destinationCoordinate
                                   ];
                 
                 // Preselect the first available route, which is the shortest
                 [self routeSelectedWithRoute:route
                                    withIndex:1];
             }
             

         } ifFailure:^(NSError *error) {
             [self displayFailureMessage:@"Failed to Fetch Routes!"];
             self.fetchedRoutes = nil;
         }];
    }else{
        [self displayNoInternetMessage];
    }
}

- (NSString *)cellIndentiferForType:(GTCreateRide_cellType)cellType{

    NSString *cellIdentifier = nil;
    switch (cellType) {
        case cellType_rideType:
            cellIdentifier = kCellIdentifier_imdrivingOrNeedARide;
            break;
        case cellType_fromLocation:
            cellIdentifier = kCellIdentifier_iconKeyValue;
            break;
        case cellType_toLocation:
            cellIdentifier = kCellIdentifier_iconKeyValue;
            break;
        case cellType_date:
            cellIdentifier = kCellIdentifier_iconKeyValue;
            break;
        case cellType_daySelection:
            cellIdentifier = kCellIdentifier_daySelection;
            break;
        case cellType_route:
            cellIdentifier = kCellIdentifier_iconKeyValue;
            break;
        case cellType_seatCost:
            cellIdentifier = kCellIdentifier_seatCountAndCost;
            break;
        case cellType_rideVisibility:
            cellIdentifier = kCellIdentifier_rideVisibility;
            break;
        case cellType_facebook:
            cellIdentifier = kCellIdentifier_facebookShare;
            break;
        case cellType_travellingWith:
            cellIdentifier = kCellIdentifier_iconKeyValue;
            break;

        default:
            break;
    }
    return cellIdentifier;
}

- (NSIndexPath *)indexPathForCellType:(GTCreateRide_cellType)cellType{
    
    NSIndexPath *indexPath = nil;
    if (_selectedUserType == userType_driving) {
        switch (cellType) {
                
                // SECTION 1
            case cellType_fromLocation:
                indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                break;
            case cellType_toLocation:
                indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                break;
            case cellType_date:
                indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                break;

                // SECTION 2
            case cellType_route:
                indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                break;

                // SECTION 3
            case cellType_rideType:
                indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
                break;
                
                // SECTION 4
            case cellType_seatCost:
                indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
                break;

                // SECTION 5
            case cellType_rideVisibility:
                indexPath = [NSIndexPath indexPathForRow:0 inSection:4];
                break;

                // SECTION 6
            case cellType_travellingWith:
                indexPath = [NSIndexPath indexPathForRow:0 inSection:5];
                break;

            default:
                break;
        }

    }else if (_selectedUserType == userType_passenger){
        switch (cellType) {
                // SECTION 1
            case cellType_fromLocation:
                indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                break;
            case cellType_toLocation:
                indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                break;
            case cellType_date:
                indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                break;

                // SECTION 2
            case cellType_route:
                indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                break;

                // SECTION 3
            case cellType_rideType:
                indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
                break;

                // SECTION 4
            case cellType_seatCost:
                indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
                break;
                
                // SECTION 5
            case cellType_rideVisibility:
                indexPath = [NSIndexPath indexPathForRow:0 inSection:4];
                break;
                
            default:
                break;

        }
    }else{
        switch (cellType) {
                // SECTION 1
            case cellType_fromLocation:
                indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                break;
            case cellType_toLocation:
                indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                break;
            case cellType_date:
                indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                break;
            case cellType_travellingWith:
                indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                break;
            case cellType_rideType:
                indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
                break;
            default:
                break;
        }
        
    }
    return indexPath;
}

- (NSString *)stringValueForCellType:(GTCreateRide_cellType)cellType{
   
    NSString *stringValue = nil;
    switch (cellType) {
        case cellType_rideType:
            stringValue = @"rideType";
            break;
        case cellType_fromLocation:
            stringValue = @"fromLocation";
            break;
        case cellType_toLocation:
            stringValue = @"toLocation";
            break;
        case cellType_date:
            stringValue = @"date";
            break;
        case cellType_daySelection:
            stringValue = @"daySelection";
            break;
        case cellType_route:
            stringValue = @"route";
            break;
        case cellType_seatCost:
            stringValue = @"seatCost";
            break;
        case cellType_rideVisibility:
            stringValue = @"rideVisibility";
            break;
        case cellType_facebook:
            stringValue = @"facebookShare";
            break;
        case cellType_travellingWith:
            stringValue = @"travellingWith";
            break;

        default:
            break;
    }
    return stringValue;
}

#pragma mark TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    if (_selectedUserType == userType_driving) {
        return [_imDrivingCellArray count];
    }else{
        return [_iNeedRideCellArray count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (_selectedUserType == userType_driving) {
        NSArray *sectionArray = [_imDrivingCellArray objectAtIndex:section];
        return [sectionArray count];
    }else{
        NSArray *sectionArray = [_iNeedRideCellArray objectAtIndex:section];
        return [sectionArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GTCreateRide_cellType cellType;
    NSArray *sectionArray = nil;
    if (_selectedUserType == userType_driving) {
        sectionArray = [_imDrivingCellArray objectAtIndex:indexPath.section];
        cellType =  [[sectionArray objectAtIndex:indexPath.row] integerValue];
    }else{
        sectionArray = [_iNeedRideCellArray objectAtIndex:indexPath.section];
        cellType =  [[sectionArray objectAtIndex:indexPath.row] integerValue];
    }

    NSString *cellIdentifier = [self cellIndentiferForType:cellType];
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:cellIdentifier
                             forIndexPath:indexPath
                             ];
    if ([cell isKindOfClass:[GTTableCell_CreateRide_DrivingOrNeedARide class]]) {
       
        GTTableCell_CreateRide_DrivingOrNeedARide *rideTypeSelectorCell =
        (GTTableCell_CreateRide_DrivingOrNeedARide *)cell;
        [rideTypeSelectorCell setDelegate:self];
        [rideTypeSelectorCell setUserType:_selectedUserType];
        
    }else if ([cell isKindOfClass:[GTTableCell_CreateRide_IconKeyValue class]]){
        GTTableCell_CreateRide_IconKeyValue *iconKeyValueCell =
        (GTTableCell_CreateRide_IconKeyValue *)cell;
        NSDictionary *dataDict = [_cellDataDictionary valueForKey:[self stringValueForCellType:cellType]];

        GTRowIndex index ;
        if ([sectionArray count] == 1) {
            index = rowIndex_independent;
        }else if (indexPath.row == 0){
            index = rowIndex_top;
        }else if (indexPath.row == [sectionArray count]-1){
            index = rowIndex_bottom;
        }else{
            index = rowIndex_middle;
        }
        
        [iconKeyValueCell setIcon:[dataDict valueForKey:kCellDataDict_image]
                              key:[dataDict valueForKey:kCellDataDict_key]
                            value:[dataDict valueForKey:kCellDataDict_value]
                      andRowIndex:index
         ];
    }else if ([cell isKindOfClass:[GTTableCell_CreateRide_rideVisiblilty class]]){
        GTTableCell_CreateRide_rideVisiblilty *shareWithCell = (GTTableCell_CreateRide_rideVisiblilty *)cell;

        [shareWithCell setDelegate:self];
        shareWithCell.visibilityControl.switchType = switchType_visibility;
        
        if (_selectedShareWith == shareWith_everybody) {
            [shareWithCell.visibilityControl setOn:NO];
        }else{
            [shareWithCell.visibilityControl setOn:YES];
        }
    }else if ([cell isKindOfClass:[GTTableCell_CreateRide_SeatCountAndCost class]]){
        GTTableCell_CreateRide_SeatCountAndCost *seatCountCell = (GTTableCell_CreateRide_SeatCountAndCost *)cell;
        [seatCountCell setDelegate:self];
        [seatCountCell setCost:self.event.seatPriceValue];
        [seatCountCell setSeatCount:self.event.availableSeats.intValue];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 10.0;
    }else{
        return 0.5;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    float cellHeight =0.0f;
    GTCreateRide_cellType cellType;
    if (_selectedUserType == userType_driving) {
        NSArray *sectionArray = [_imDrivingCellArray objectAtIndex:indexPath.section];
        cellType =  [[sectionArray objectAtIndex:indexPath.row] integerValue];
    }else{
        NSArray *sectionArray = [_iNeedRideCellArray objectAtIndex:indexPath.section];
        cellType =  [[sectionArray objectAtIndex:indexPath.row] integerValue];
    }

    switch (cellType) {
        case cellType_rideType:
            cellHeight = kCellHeight_rideType;
            break;
        case cellType_fromLocation:
            cellHeight = kCellHeight_fromLocation;
            break;
        case cellType_toLocation:
            cellHeight = kCellHeight_toLocation;
            break;
        case cellType_date:
            cellHeight = kCellHeight_date;
            break;
        case cellType_travellingWith:
            cellHeight = kCellHeight_travellingWith;
            break;
        case cellType_daySelection:
            cellHeight = kCellHeight_daySelection;
            break;
        case cellType_route:
            cellHeight = kCellHeight_route;
            break;
        case cellType_seatCost:
            cellHeight = kCellHeight_seatCost;
            break;
        case cellType_rideVisibility:
            cellHeight = kCellHeight_rideVisibility;
            break;
        default:
            break;
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    GTCreateRide_cellType selectedCellType;
    if (_selectedUserType == userType_driving) {
        NSArray *sectionArray = [_imDrivingCellArray objectAtIndex:indexPath.section];
        selectedCellType =  [[sectionArray objectAtIndex:indexPath.row] integerValue];
    }else{
        NSArray *sectionArray = [_iNeedRideCellArray objectAtIndex:indexPath.section];
        selectedCellType =  [[sectionArray objectAtIndex:indexPath.row] integerValue];
    }

    switch (selectedCellType) {
        case cellType_fromLocation:
            [self fromLocationCellSelected];
            break;
        case cellType_toLocation:
            [self toLocationCellSelected];
            break;
        case cellType_date:
            [self dateCellSelected];
            break;
        case cellType_daySelection:
            [self dateCellSelected];
            break;
        case cellType_route:
            [self routeCellSelected];
            break;
        case cellType_travellingWith:
            [self travellingWithSelected];
            break;

        default:
            break;
    }    
}

#pragma mark - VisibilityCell Delegates
- (void)visibilityButtonValueChanged:(GTShareWith)shareWith{
    
    if ([[TAFacebookManager sharedInstance] isFacebookConnected] == NO){
        
        [self displayFailureMessage:@"Connect to facebook!"];
        
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            _selectedShareWith = shareWith_everybody;
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[self indexPathForCellType:cellType_rideVisibility]]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            
        });
        
    }
}

#pragma mark - GTTableCellRiderSelectorDelegate

- (void)rideTypeSelected:(GTUserType)userType{
    self.selectedUserType = userType;
    [self.tableView reloadData];
}

#pragma mark - GTFriendsSelected delegate
- (void)friendsSelected:(NSArray *)friends{

    self.taggedFriends = friends;
    NSMutableString *taggedFriendsIds = [[NSMutableString alloc] init];
    for (User *friend in friends) {
        [taggedFriendsIds appendString:friend.userId];
        if ([[friends lastObject] isEqual:friend] == NO) {
            [taggedFriendsIds appendString:@","];
        }
    }
    [self.event setCoTravellers:taggedFriendsIds];
    
    // SET the value in data dictionary
    NSMutableString *displayString = [[NSMutableString alloc] init];
    int taggedFriendsCount = [self.taggedFriends count];
    User *friend = [self.taggedFriends lastObject];
    if (taggedFriendsCount == 1) {
        [displayString appendString:friend.name];
    }else if (taggedFriendsCount > 1){
        [displayString appendString:friend.name];
        [displayString appendFormat:@" + %d others",taggedFriendsCount-1];
    }else if (taggedFriendsCount == 0){
        [displayString appendFormat:@"alone ?"];
    }
    NSDictionary *dictionary = [_cellDataDictionary objectForKey:[self stringValueForCellType:cellType_travellingWith]];
    [dictionary setValue:displayString forKey:kCellDataDict_value];
    [_cellDataDictionary setValue:dictionary forKey:[self stringValueForCellType:cellType_travellingWith]];

    // RELOAD TABLE DATA
    [self.tableView reloadData];
}

#pragma mark - Flurry
- (void)flurrylogcreateRideWithDetails:(Event *)event{
    
    GTFlurryManager *flurryManager = [GTFlurryManager sharedInstance];
    
    GTRequestType requestType;
    if([_event.userType isEqualToString:@"owner"]){
        requestType = GTRequestTypeOffer;
    }else{
        requestType = GTRequestTypeAsk;
    }
    
    GTRideType rideType;
    if([event.eventType isEqualToString:@"friends"]){
        rideType = GTRideTypeFriend;
    }else{
        rideType = GTRideTypePublic;
    }
    
    [flurryManager logCreateRideForRideType:rideType andRequestType:requestType];

    if (requestType == GTRequestTypeOffer) {
        [flurryManager logSeatCount:event.availableSeatsValue forRideType:rideType];
        [flurryManager logRideLength:event.routeDistanceValue forRideType:rideType];
        
        double costPerKM = event.routeDistanceValue/event.seatPriceValue;
        [flurryManager logCostPerKM:costPerKM forRideType:rideType];
    }
}
@end
