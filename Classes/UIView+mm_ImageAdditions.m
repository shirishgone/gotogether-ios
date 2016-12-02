/*
 UIView+ImageAdditions.m
 
 Contributors:
 Conrad Stoll on 2/15/12.
 
 Copyright (c) 2012 gotogether. All rights reserved.
 */

#import "UIView+mm_ImageAdditions.h"
#import "UIImage+GTBlurring.h"

#ifndef QUARTZCORE_H
#error Missing QuartzCore framework
#endif

@implementation UIView (mm_ImageAdditions)

- (UIImage*)mm_imageFromLayer {
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return viewImage;
}

- (void)fadeIn{
    self.alpha = 0.0;
    [UIView animateWithDuration:kAnimationDuration_fadeIn
                     animations:^{
                         self.alpha = 1.0;
                     }];

}

+ (UIView *)headerViewWithTitle:(NSString *)title{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [headerView setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.0]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 200, 20)];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setText:title];
    [headerView addSubview:titleLabel];
    return headerView;
}

#pragma mark - blur background picture
- (void)setupBackgroundBlurPicture:(UIImage *)image{
    
    if (image != nil) {
        UIImage *blurredImage = [image blurredImageWithBlurRadius:10.0];
        UIImageView *blurredImageView = [[UIImageView alloc] initWithImage:blurredImage];
        blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
        blurredImageView.clipsToBounds = YES;
        [blurredImageView setFrame:self.bounds];
        [self addSubview:blurredImageView];
        [self sendSubviewToBack:blurredImageView];
        [self setNeedsDisplay];
        [blurredImageView fadeIn];
    }
}
@end
