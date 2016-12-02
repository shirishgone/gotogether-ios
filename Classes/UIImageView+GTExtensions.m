//
//  UIImageView+GTExtensions.m
//  goTogether
//
//  Created by Shirish on 2/9/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "UIImageView+GTExtensions.h"

@implementation UIImageView (GTExtensions)

- (void)scaleProfilePic{
    [self setContentMode:UIViewContentModeScaleAspectFill];
    float imageWidth = self.frame.size.width;
    self.layer.cornerRadius = imageWidth / 2.0;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 0.0;
}
@end
