//
//  UIImage+UBBlurring.m
//  UnionBank
//
//  Created by Shirish Gone on 11/20/13.
//  Copyright (c) 2013 GoTogether. All rights reserved.
//

#import "UIImage+GTBlurring.h"
#import <Accelerate/Accelerate.h>

static const NSInteger kDefaultBlurRadius = 10.0;

@implementation UIImage (GTBlurring)

- (UIImage *)blurredImage {
    return [self blurredImageWithBlurRadius:kDefaultBlurRadius];
}

- (UIImage *)blurredImageWithBlurRadius:(NSInteger)blurRadius {
    CGRect frame = CGRectMake(0, 0, self.size.width, self.size.height);
    return [self blurredPortionOfImageInFrame:frame withBlurRadius:blurRadius];
}


- (UIImage *)blurredPortionOfImageInFrame:(CGRect)frame {
    return [self blurredPortionOfImageInFrame:frame withBlurRadius:kDefaultBlurRadius];
}

- (UIImage *)blurredPortionOfImageInFrame:(CGRect)frame withBlurRadius:(NSInteger)blurRadius {
    blurRadius *= [[UIScreen mainScreen] scale];
    if (blurRadius % 2 == 0) {
        blurRadius += 1;
    }
    vImage_Buffer inBuffer;
    vImage_Buffer outBuffer;
    CGFloat bitsPerComponent = 8.0;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], frame);
    
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    
    CGSize targetSize = CGSizeMake(frame.size.width, frame.size.height);
    CGContextRef imageContext = CGBitmapContextCreate(NULL,
                                                      targetSize.width,
                                                      targetSize.height,
                                                      bitsPerComponent,
                                                      bytesPerRow,
                                                      colorSpace,
                                                      CGImageGetBitmapInfo(imageRef) | CGImageGetAlphaInfo(imageRef));
    CGContextDrawImage(imageContext, CGRectMake(0, 0, targetSize.width, targetSize.height), imageRef);
    
    inBuffer.data = CGBitmapContextGetData(imageContext);
    inBuffer.width = targetSize.width;
    inBuffer.height = targetSize.height;
    inBuffer.rowBytes = bytesPerRow;
    
    outBuffer.data = malloc(bytesPerRow * targetSize.height);
    outBuffer.width = targetSize.width;
    outBuffer.height = targetSize.height;
    outBuffer.rowBytes = bytesPerRow;
    
    vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, blurRadius, blurRadius, NULL, kvImageEdgeExtend);
    vImageBoxConvolve_ARGB8888(&outBuffer, &inBuffer, NULL, 0, 0, blurRadius, blurRadius, NULL, kvImageEdgeExtend);
    vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, blurRadius, blurRadius, NULL, kvImageEdgeExtend);
    
    CGContextRef convolvedContext = CGBitmapContextCreate(outBuffer.data,
                                                          outBuffer.width,
                                                          outBuffer.height,
                                                          bitsPerComponent,
                                                          outBuffer.rowBytes,
                                                          colorSpace,
                                                          CGImageGetBitmapInfo(imageRef) | CGImageGetAlphaInfo(imageRef));
    
    CGImageRef convolvedImage = CGBitmapContextCreateImage(convolvedContext);
    
    UIImage *returnImage = [UIImage imageWithCGImage:convolvedImage scale:1.0 orientation:self.imageOrientation];
    free(outBuffer.data);
    
    CGImageRelease(imageRef);
    CGImageRelease(convolvedImage);
    
    CGContextRelease(convolvedContext);
    CGContextRelease(imageContext);
    
    CGColorSpaceRelease(colorSpace);
    
    return returnImage;
}
@end
