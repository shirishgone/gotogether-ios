//
//  NSString+GTExtensions.m
//  goTogether
//
//  Created by Shirish on 2/9/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "NSString+GTExtensions.h"

@implementation NSString (GTExtensions)

- (CGFloat)heightOfStringWithFont:(UIFont *)font constrainedSize:(CGSize )size{
    CGFloat calculatedHeight ;
    
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        
        CGRect calculatedRect = [self boundingRectWithSize:size
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:font}
                                                   context:nil
                                 ];
        calculatedHeight = calculatedRect.size.height;
    }else{
        calculatedHeight = [self sizeWithFont:font constrainedToSize:size].height;
    }
    
    return ceil(calculatedHeight);
}

- (BOOL)containtsSubStirng:(NSString *)subString {
    if ([self rangeOfString:subString].location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)isStringAvailable {
    if (self!= nil) {
        NSString *aboutString = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([aboutString length] > 0) {
            return YES;
        }
    }
    return NO;
}

@end
