//
//  GTProfileTableCell_Name.m
//  goTogether
//
//  Created by shirish on 08/07/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTProfilePersonalDetailsTableCell.h"
#import "NSString+GTExtensions.h"

@interface GTProfilePersonalDetailsTableCell()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *ageLabel;
@property (nonatomic, weak) IBOutlet UILabel *genderLabel;
@property (nonatomic, weak) IBOutlet UILabel *bioLabel;

@end


@implementation GTProfilePersonalDetailsTableCell

- (void)setUser:(User *)user {
    _user = user;

    [self setName:user.name];
    [self setAge:[user.dateOfBirth ageString]];
    [self setGender:user.gender];
    [self setBio:user.profileDescription];
}

#pragma mark - Setters

- (void)setName:(NSString *)nameString {
    if (nameString== nil) {
        [self.nameLabel setText:@"NA"];
    }else{
        [self.nameLabel setText:nameString];
    }
}

- (void)setAge:(NSString *)ageString {
    if (ageString== nil) {
        [self.ageLabel setText:@"NA"];
    }else{
        [self.ageLabel setText:[ageString uppercaseString]];
    }
}

- (void)setGender:(NSString *)genderString {
    if (genderString == nil) {
        [self.genderLabel setText:@"NA"];
    }else{
        [self.genderLabel setText:[genderString uppercaseString]];
    }
}

- (void)setBio:(NSString *)bioString {
    if ([bioString isStringAvailable] == NO) {
        [self.bioLabel setText:@"NA"];
    }else{
        [self.bioLabel setText:bioString];
    }
}

@end
