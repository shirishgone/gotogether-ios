//
//  TASeachLocationControllerViewController.m
//  goTogether
//
//  Created by shirish on 05/02/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTSearchGooglePlaceController.h"
#import "Place.h"
#import "TAGoogleAPIManager.h"
#import "goTogetherAppDelegate.h"
#import "Place.h"

@interface GTSearchGooglePlaceController ()
@property (nonatomic, strong) NSArray *savedLocations;
@property (nonatomic, strong) NSMutableArray *searchedLocations;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
- (IBAction)cancelButtonTouched:(id)sender;
@end

@implementation GTSearchGooglePlaceController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.searchedLocations = [NSMutableArray array];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self trackScreenName:@"SearchPlace"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.savedLocations = [Place allPlaces];
}

- (IBAction)cancelButtonTouched:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;{
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchedLocations count];
    }else{
        return [self.savedLocations count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    Place *place = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        place = [self.searchedLocations objectAtIndex:indexPath.row];
    }else{
        place = [self.savedLocations objectAtIndex:indexPath.row];
    }

    UIFont *detailLabelFont = [UIFont fontWithName:@"Helvetica" size:12];
    CGRect textRect = [place.formattedPlaceName
                       boundingRectWithSize:CGSizeMake(280.0, 1000.0)
                       options:NSStringDrawingUsesLineFragmentOrigin
                       attributes:@{NSFontAttributeName:detailLabelFont}
                       context:nil];
    
    CGSize size = textRect.size;
    return size.height + 40.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell = nil;

    static NSString *cellIndentifier = @"SearchDisplayControllerCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];

    if (cell == nil) {

        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentifier];
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [cell.detailTextLabel setNumberOfLines:3];
    }

    Place *place = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        place = [self.searchedLocations objectAtIndex:indexPath.row];
    }else{
        place = [self.savedLocations objectAtIndex:indexPath.row];
    }

    [cell.textLabel setText:place.placeName];
    [cell.detailTextLabel setText:place.formattedPlaceName];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    Place *selectedPlace = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        selectedPlace = [self.searchedLocations objectAtIndex:indexPath.row];

        [self saveSelectedPlace:selectedPlace];
        [self dismissAnddelegatePlace:selectedPlace];
    }else{
        selectedPlace = [self.savedLocations objectAtIndex:indexPath.row];
        [self dismissAnddelegatePlace:selectedPlace];
    }
}

- (void)saveSelectedPlace:(Place *)place{
    [Place savePlaceWithPlaceName:place.placeName
                        reference:place.reference
                         latitude:place.latitude
                        longitude:place.longitude
                  subLocalityName:place.subLocalityName
                     localityName:place.localityName
                 formattedAddress:place.formattedPlaceName
     ];
}

- (void)dismissAnddelegatePlace:(Place *)place{
    if ([self.delegate respondsToSelector:@selector(selectedPlace:)]) {
        [self.delegate selectedPlace:place];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma Mark SearchBar Display Controller

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    TALog(@"search Text : %@",searchText);
    if (searchText.length > 3) {
        [self searchPlacesWithString:searchBar.text];
    }
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!appDelegate.window.isKeyWindow) {
        [appDelegate.window makeKeyAndVisible];
    }
}
- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{

    [controller setActive:YES animated:YES];
    _searchBar.showsScopeBar = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];

    if (searchBar.text == nil || searchBar.text.length == 0) {
        [self displayFailureMessage:@"Please enter a location Name"];
    }
    else{
        [self searchPlacesWithString:searchBar.text];
    }

}

- (void)searchPlacesWithString:(NSString *)searchBarText {

    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.netStatus != kNotReachable) {
        
        [self displayActivityIndicatorViewWithMessage:@"Searching for location..."];
        TAGoogleAPIManager *googleAPIManager = [TAGoogleAPIManager sharedInstance];
        [googleAPIManager placesForString:searchBarText
         ifSucess:^(NSArray *places){

             [self hideStatusMessage];
             [self.searchedLocations removeAllObjects];
             [self.searchedLocations addObjectsFromArray:places];
             [self.searchDisplayController.searchResultsTableView reloadData];
             
         } ifFailure:^(NSError *error) {
             
             [self displayFailureMessage:@"Unable to fetch location."];
             [_searchedLocations removeAllObjects];
             [self.searchDisplayController.searchResultsTableView reloadData];
         }
         ];
    }
    else {
        [self displayNoInternetMessage];
    }

}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {

    [controller setActive:NO animated:YES];
    [controller.searchBar resignFirstResponder];
}

@end
