//
//  GTProfileTableCell_description.m
//  goTogether
//
//  Created by shirish on 08/07/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "GTProfileTableCell_description.h"
@interface GTProfileTableCell_description()
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UIView *bckgdView;
@end
@implementation GTProfileTableCell_description

- (void)awakeFromNib{
    [self addBorderToBackground];
}

- (void)setProfileDescription:(NSString *)description{
    [self.descriptionLabel setText:description];
    [self updateDescriptionLabelFrameForDescription:description];
}

- (void)updateDescriptionLabelFrameForDescription:(NSString *)description{
    
    CGRect textRect = [description boundingRectWithSize:_descriptionLabel.frame.size
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:_descriptionLabel.font}
                                                context:nil];
    
    CGSize size = textRect.size;
    
    
    
//    CGSize size = [description sizeWithFont:_descriptionLabel.font
//                          constrainedToSize:_descriptionLabel.frame.size
//                              lineBreakMode:_descriptionLabel.lineBreakMode];
    
    [_descriptionLabel setFrame:CGRectMake(10.0,
                                           5.0,
                                           _bckgdView.frame.size.width - 20.0,
                                           size.height)];
}

- (void)addBorderToBackground{
    [self.bckgdView.layer setCornerRadius:3.0];
    [self.bckgdView.layer setBorderWidth:1.0];
    [self.bckgdView.layer setBorderColor:kColorBorderLine.CGColor];
}

@end
