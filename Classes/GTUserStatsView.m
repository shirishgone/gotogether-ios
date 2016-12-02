//
//  GTUserStatsView.m
//  goTogether
//
//  Created by shirish on 12/12/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTUserStatsView.h"

@interface GTUserStatsView()
@property (nonatomic, strong) User *user;
@property (nonatomic, weak) IBOutlet UILabel *ridesCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *ratingLabel;
@property (nonatomic, weak) IBOutlet UILabel *carbonFootPrintLabel;
@end

@implementation GTUserStatsView
- (void)setStatsForUser:(User *)user{
    self.user = user;
    //TODO: Set User Stats here.
}

@end
