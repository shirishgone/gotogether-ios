//
//  GTTableViewCellType1.m
//  goTogether
//
//  Created by shirish on 27/03/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "GTTableCell_CreateRide_IconKeyValue.h"


@interface GTTableCell_CreateRide_IconKeyValue()
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UILabel *keyLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;
@end

@implementation GTTableCell_CreateRide_IconKeyValue

//- (void)awakeFromNib{
//    [self setFontsAndColors];
//}

- (void)setIcon:(UIImage *)iconImage
            key:(NSString *)keyString
          value:(NSString *)valueString
    andRowIndex:(GTRowIndex)index
{

    [_iconImageView setImage:iconImage];
    [_keyLabel setText:keyString];
    [_valueLabel setText:valueString];
    
    UIImage *backgroundImage = nil;
    switch (index) {
        case rowIndex_bottom:
            backgroundImage = [UIImage imageNamed:@"txt_field_bottom.png"];
            break;
        case rowIndex_middle:
            backgroundImage = [UIImage imageNamed:@"txt_field_middle.png"];
            break;
        case rowIndex_top:
            backgroundImage = [UIImage imageNamed:@"txt_field_top.png"];
            break;
        case rowIndex_independent:
            backgroundImage = [UIImage imageNamed:@"bg_text_field.png"];
            break;
        default:
            break;
    }
    [self.backgroundImageView setImage:backgroundImage];
    
}

//- (void)setFontsAndColors{
//    [_keyLabel setFont:kFont_HelveticaNeueBold_13];
//    [_keyLabel setTextColor:kTextColorBlack];
//    [_keyLabel setTextAlignment:NSTextAlignmentLeft];
//    
//    [_valueLabel setFont:kFont_HelveticaNeueRegular_14];
//    [_valueLabel setTextColor:kTextColorBlue];
//    [_valueLabel setTextAlignment:NSTextAlignmentCenter];
//}

@end
