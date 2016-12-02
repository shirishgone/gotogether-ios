//
//  UIView+Parallax.h
//  UnionBank
//
//  Created by Jeffrey Sassen on 12/2/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

@interface UIView (Parallax)

/**
 Adds a parallax effect to the view.
 @param minimumAndMaximumRelativeValue The minimum and maximum relative value to the current 
        position. For instance, inserting a 10 would give the view a maximum x and y offset of 10
        pixels positive or negative.
 */
- (void)addParallaxEffectWithMinimumAndMaximumRelativeValue:(NSInteger)minimumAndMaximumRelativeValue;
- (void)addHorizantalParallaxEffectWithMinimumAndMaximumRelativeValue:(NSInteger)minimumAndMaximumRelativeValue ;

/**
 Removes any parallax effects from the view.
 */
- (void)removeParallaxEffect;

@end
