//
//  GTHomeAndWorkPlaceViewController.m
//  goTogether
//
//  Created by shirish on 03/01/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTHomeAndWorkPlaceViewController.h"
#import "GTSearchGooglePlaceController.h"

@interface GTHomeAndWorkPlaceViewController ()<TASearchLocationControllerDelegate>
@property (readwrite, nonatomic) GTSearchLocationType currentSearchType;
@property (nonatomic, weak) IBOutlet UILabel *homePlaceLabel;
@property (nonatomic, weak) IBOutlet UILabel *workPlaceLabel;

@property (nonatomic, strong) Place *home;
@property (nonatomic, strong) Place *work;
@end

@implementation GTHomeAndWorkPlaceViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row ==0) {
        [self homePlaceTouched:nil];
    }else{
        [self workPlaceTouched:nil];
    }
}

#pragma mark - action handlers
- (void)homePlaceTouched:(id)sender{
    _currentSearchType = SourceSearch;
    [self performSegueWithIdentifier:kSegueIdentifier_registrationToSearchLocation
                              sender:nil];
}

- (void)workPlaceTouched:(id)sender{
    _currentSearchType = DestinationSearch;
    [self performSegueWithIdentifier:kSegueIdentifier_registrationToSearchLocation
                              sender:nil];
}

- (IBAction)cancelTouched:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveTouched:(id)sender{
    //TODO: Update user profile with home and work places.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:kSegueIdentifier_registrationToSearchLocation]) {
        UINavigationController *navigationController = segue.destinationViewController;
        GTSearchGooglePlaceController *searchViewController = [navigationController.viewControllers objectAtIndex:0];
        
        searchViewController.delegate = self;
    }
}

#pragma mark search entry delegate
#pragma mark - search location controller delegates
- (void)selectedPlace:(Place *)place{
    
    TALog(@"place: %@",place);
//    if (_currentSearchType == SourceSearch) {
//        self.home = place;
//        [self.homePlaceLabel setText:place.placeName];
//    }else{
//        self.work = place;
//        [self.workPlaceLabel setText:place.placeName];
//    }
}

@end
