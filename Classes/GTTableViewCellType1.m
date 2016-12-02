//
//  GTTableViewCellType1.m
//  goTogether
//
//  Created by shirish on 27/03/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "GTTableViewCellType1.h"


@interface GTTableViewCellType1()
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UILabel *keyLabel;
@property (nonatomic, weak) IBOutlet UIButton *valueLabel;
@end

@implementation GTTableViewCellType1

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *viewObjects = [[NSBundle mainBundle] loadNibNamed:@"GTTableViewCellType1" owner:self options:nil];
        self = [viewObjects objectAtIndex:0];
    }
    return self;
}

- (void)setIcon:(UIImage *)iconImage
            key:(NSString *)keyString
       andValue:(NSString *)valueString
{
    [_iconImageView setImage:iconImage];
    [_keyLabel setText:keyString];
    [_valueLabel setTitle:valueString forState:UIControlStateNormal];
}
@end
