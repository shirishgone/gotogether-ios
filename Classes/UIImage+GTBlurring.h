//
//  UIImage+UBBlurring.h
//  UnionBank
//
//  Created by Shirish Gone on 11/20/13.
//  Copyright (c) 2013 GoTogether. All rights reserved.
//

/**
 A helper category for blurring UIImages.
 */
@interface UIImage (GTBlurring)

/**
 Returns a blurred image of the UIImage using a default blurRadius.
 */
- (UIImage *)blurredImage;

/**
 Returns a blurred image of the UIImage using the given blurRadius.
 @param blurRadius The blur radius to be applied to the UIImage
 */
- (UIImage *)blurredImageWithBlurRadius:(NSInteger)blurRadius;

/**
 Returns a blurred portion of the UIImage using a default blurRadius.
 @param frame The portion of the UIImage to be cropped, blurred and returned
 */
- (UIImage *)blurredPortionOfImageInFrame:(CGRect)frame;

/**
 Returns a blurred portion of the UIImage using the given blurRadius.
 @param frame The portion of the UIImage to be cropped, blurred and returned
 @param blurRadius The blur radius to be applied to the UIImage
 */
- (UIImage *)blurredPortionOfImageInFrame:(CGRect)frame withBlurRadius:(NSInteger)blurRadius;

@end
