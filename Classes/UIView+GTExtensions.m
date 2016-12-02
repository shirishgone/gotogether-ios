//
//  UIView+GTExtensions.m
//  goTogether
//
//  Created by shirish on 14/07/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "UIView+GTExtensions.h"

@implementation UIView(GTExtensions)

- (void) shake {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.duration = 0.6;
    animation.values = @[ @(-20), @(20), @(-20), @(20), @(-10), @(10), @(-5), @(5), @(0) ];
    [self.layer addAnimation:animation forKey:@"shake"];
}

@end
