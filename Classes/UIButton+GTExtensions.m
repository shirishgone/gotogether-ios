//
//  UIButton+GTExtensions.m
//  goTogether
//
//  Created by Pavan Krishna on 22/04/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "UIButton+GTExtensions.h"

@implementation UIButton (GTExtensions)

+ (UIButton *)addBorderToButton:(UIButton *)button{
    
    [button setBackgroundColor:kColorPalette_baseColor];
    [button.layer setBorderColor:[button.backgroundColor CGColor]];
    [button.layer setBorderWidth:1.0];
    [button.layer setCornerRadius:5.0];
    return button;
}

+ (UIButton *)searchButton{
    UIImage *buttonImage = [UIImage imageNamed:@"search_icon"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setTranslatesAutoresizingMaskIntoConstraints:YES];
    return button;
}

+ (UIButton *)plusButton{
    UIImage *buttonImage = [UIImage imageNamed:@"nav_plus"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setTranslatesAutoresizingMaskIntoConstraints:YES];
    return button;
}

+ (UIButton *)facebookButton{
    UIImage *facebookButtonImage_normal = [[UIImage imageNamed:@"btn_connect_fb_normal.png"]
                                           stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    UIImage *facebookButtonImage_selected = [[UIImage imageNamed:@"btn_connect_fb_pressed.png"]
                                             stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(18, 15, 284, facebookButtonImage_normal.size.height)];
    [button setBackgroundImage:facebookButtonImage_normal forState:UIControlStateNormal];
    [button setBackgroundImage:facebookButtonImage_selected forState:UIControlStateHighlighted];
    [button setTitle:@"Autofill with Facebook" forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]];
    [button setTranslatesAutoresizingMaskIntoConstraints:YES];
    return button;
}
@end
