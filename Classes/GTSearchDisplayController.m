//
//  GTSearchDisplayController.m
//  goTogether
//
//  Created by shirish on 19/09/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "GTSearchDisplayController.h"

@implementation GTSearchDisplayController

- (void)awakeFromNib{
    [self.searchResultsTableView setAllowsMultipleSelection:YES];
}

- (void)setActive:(BOOL)visible animated:(BOOL)animated;
{
    if(self.active == visible) return;
    [self.searchContentsController.navigationController setNavigationBarHidden:YES animated:NO];
    [super setActive:visible animated:animated];
    [self.searchContentsController.navigationController setNavigationBarHidden:NO animated:NO];
    if (visible) {
        [self.searchBar becomeFirstResponder];
    } else {
        [self.searchBar resignFirstResponder];
    }
}
@end
