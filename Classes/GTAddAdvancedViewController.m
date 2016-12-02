//
//  GTAddAdvancedViewController.m
//  goTogether
//
//  Created by shirish on 13/08/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTAddAdvancedViewController.h"
#import "RCSwitchOnOff.h"
#import "GTFriendsListViewController.h"
#import "GTGoogleMapsRouteViewController.h"

@interface GTAddAdvancedViewController ()
<GTFriendsSelectedDelegate,
TAGoogleMapsRouteSelectorDelegate>

@property (nonatomic, strong) NSArray *taggedFriends;
@property (nonatomic, strong) TARoute *selectedRoute;

@property (nonatomic, assign) BOOL passedValues;
@property (nonatomic, weak) IBOutlet UILabel *seatCountLabel;
@property (nonatomic, weak) IBOutlet UITextField *costTextField;
@property (nonatomic, weak) IBOutlet UIStepper *seatsStepper;

@property (nonatomic, weak) IBOutlet UILabel *routeLabel;
@property (nonatomic, weak) IBOutlet UILabel *friendsLabel;

- (IBAction)stepperValueChanged:(id)sender;
- (IBAction)doneButtonTouched:(id)sender;
@end

@implementation GTAddAdvancedViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initialiseData];
    [self setupDoneButtonBarForPriceKeyboard];
}

- (void)initialiseData{
    [self initialiseSeatStepper];

    if (self.passedValues) {
        [self.friendsLabel setText:[self displayStringForTaggedFriends]];
        if (self.seatPrice > 0) {
            [self.costTextField setText:[NSString stringWithFormat:@"%.0f",self.seatPrice]];
        }
    }else{
        [self.costTextField setText:[NSString stringWithFormat:@"%.0f",self.seatPrice]];
    }
}

- (void)initialiseSeatStepper{
    [self.seatsStepper setMinimumValue:1.0];
    [self.seatsStepper setMaximumValue:5.0];
    [self.seatsStepper setValue:1.0];
    [self updateSeatCountLabel];
}

- (void)setSelectedSeatCount:(int)count
                   seatPrice:(float)seatPrice
                 withFriends:(NSArray *)friends{
    self.seatsStepper.value = count;
    self.seatPrice = seatPrice;
    self.taggedFriends = friends;
    self.passedValues = YES;
}

#pragma mark - action handlers
- (IBAction)stepperValueChanged:(id)sender{
    [self updateSeatCountLabel];
}

- (void)updateSeatCountLabel{
    if ((int)self.seatsStepper.value == 1) {
        [_seatCountLabel setText:[NSString stringWithFormat:@"%d empty seat",(int)self.seatsStepper.value]];
    }else{
        [_seatCountLabel setText:[NSString stringWithFormat:@"%d empty seats",(int)self.seatsStepper.value]];
    }
}

- (void)selectRoute{
   
    Place *sourcePlace = [Place placeForLatitude:_sourceCoordinate.latitude
                                       longitude:_sourceCoordinate.longitude
                                            name:_sourceName
                          ];
    
    Place *destinationPlace  = [Place placeForLatitude:_destinationCoordinate.latitude
                                             longitude:_destinationCoordinate.longitude
                                                  name:_destinationName];
    
    
    UIStoryboard *storyBoard =
    [UIStoryboard storyboardWithName:kStoryBoardIdentifier
                              bundle:[NSBundle mainBundle]];
    
    GTGoogleMapsRouteViewController *routeViewController =
    [storyBoard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_routeMap];

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
    [self.navigationController pushViewController:routeViewController animated:YES];

}

- (void)chooseFriends{
    
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

- (IBAction)doneButtonTouched:(id)sender{
    if ([_delegate respondsToSelector:@selector(selectedSeatCount:price:route:taggedFriends:)]) {
        [_delegate selectedSeatCount:(int)self.seatsStepper.value
                               price:_seatPrice
                               route:_selectedRoute
                       taggedFriends:_taggedFriends
         ];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Done Button Over Price Keyboard
- (void)setupDoneButtonBarForPriceKeyboard{
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self
                                      action:@selector(doneWithNumberPad)
                                      ];
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           doneBarButton,
                           nil];
    [numberToolbar sizeToFit];
    _costTextField.inputAccessoryView = numberToolbar;
}

- (void)doneWithNumberPad{
    [_costTextField resignFirstResponder];
    NSString *costString = _costTextField.text;
    self.seatPrice = [costString doubleValue];
}

#pragma mark - table view delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 2) {
        [self selectRoute];
    }else if (indexPath.section == 3){
        [self chooseFriends];
    }
}

#pragma mark - RouteSelectorDelegates
- (void)routeSelectedWithRoute:(TARoute *)route withIndex:(NSInteger)index{
    
    [_routeLabel setText:[NSString stringWithFormat:@"Route %d",index]];
    self.selectedRoute = route;
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
    // TODO: Delegate TaggedFriends    
    [self.friendsLabel setText:[self displayStringForTaggedFriends]];
}

- (NSString *)displayStringForTaggedFriends{

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
    return displayString;

}
@end
