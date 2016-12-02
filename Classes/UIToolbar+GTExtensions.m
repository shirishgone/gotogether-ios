//
//  UIToolbar+GTExtensions.m
//  goTogether
//
//  Created by Shirish on 2/13/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "UIToolbar+GTExtensions.h"

@implementation UIToolbar (GTExtensions)

+ (UIToolbar *)GTToolBarWithDoneButtonWithDelegate:(id)delegate andSelector:(SEL)selector{
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    toolbar.translucent = YES;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"DONE" style: UIBarButtonItemStyleBordered target:delegate action:selector];
    NSDictionary *buttonAttributes =
    [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    [doneButton setTitleTextAttributes:buttonAttributes forState:UIControlStateNormal];
    
    UIBarButtonItem *flexibleWidth = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    toolbar.items = [NSArray arrayWithObjects:flexibleWidth,doneButton,flexibleWidth, nil];
    return toolbar;
}

@end
