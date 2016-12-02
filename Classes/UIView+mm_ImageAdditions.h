/*
 UIView+ImageAdditions.h
 
 Contributors:
 Conrad Stoll on 2/15/12.
 
 Copyright (c) 2012 gotogether. All rights reserved.
 */

#import <UIKit/UIKit.h>

@interface UIView (mm_ImageAdditions)

/** Returns an image of self*/
- (UIImage*)mm_imageFromLayer;
- (void)fadeIn;
- (void)setupBackgroundBlurPicture:(UIImage *)image;
+ (UIView *)headerViewWithTitle:(NSString *)title;
@end
