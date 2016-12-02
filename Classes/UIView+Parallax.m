//
//  UIView+Parallax.m
//  UnionBank
//
//  Created by Jeffrey Sassen on 12/2/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "UIView+Parallax.h"

@implementation UIView (Parallax)

- (void)addHorizantalParallaxEffectWithMinimumAndMaximumRelativeValue:(NSInteger)minimumAndMaximumRelativeValue {
    if ([self supportsParallax]) {
        
        UIInterpolatingMotionEffect *horizontalMotionEffect;
        horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                 type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        horizontalMotionEffect.minimumRelativeValue = @(-minimumAndMaximumRelativeValue);
        horizontalMotionEffect.maximumRelativeValue = @(minimumAndMaximumRelativeValue);
        
        UIMotionEffectGroup *group = [UIMotionEffectGroup new];
        group.motionEffects = @[horizontalMotionEffect];
        
        [self addMotionEffect:group];
    }
}


- (void)addParallaxEffectWithMinimumAndMaximumRelativeValue:(NSInteger)minimumAndMaximumRelativeValue {
    if ([self supportsParallax]) {
        UIInterpolatingMotionEffect *verticalMotionEffect;
        verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                               type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        verticalMotionEffect.minimumRelativeValue = @(-minimumAndMaximumRelativeValue);
        verticalMotionEffect.maximumRelativeValue = @(minimumAndMaximumRelativeValue);
        
        UIInterpolatingMotionEffect *horizontalMotionEffect;
        horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                 type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        horizontalMotionEffect.minimumRelativeValue = @(-minimumAndMaximumRelativeValue);
        horizontalMotionEffect.maximumRelativeValue = @(minimumAndMaximumRelativeValue);
        
        UIMotionEffectGroup *group = [UIMotionEffectGroup new];
        group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
        
        [self addMotionEffect:group];
    }
}

- (void)removeParallaxEffect {
    if ([self supportsParallax]) {
        NSArray *motionEffects = self.motionEffects;
        for (UIMotionEffect *motionEffect in motionEffects) {
            [self removeMotionEffect:motionEffect];
        }
    }
}

- (BOOL)supportsParallax {
    return [UIInterpolatingMotionEffect class] && [UIMotionEffectGroup class];
}

@end
