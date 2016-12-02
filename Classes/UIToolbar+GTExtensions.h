//
//  UIToolbar+GTExtensions.h
//  goTogether
//
//  Created by Shirish on 2/13/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIToolbar (GTExtensions)

+ (UIToolbar *)GTToolBarWithDoneButtonWithDelegate:(id)delegate andSelector:(SEL)selector;

@end
