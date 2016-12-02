//
//  NSString+GTExtensions.h
//  goTogether
//
//  Created by Shirish on 2/9/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (GTExtensions)

- (CGFloat)heightOfStringWithFont:(UIFont *)font constrainedSize:(CGSize )size;
- (BOOL)containtsSubStirng:(NSString *)subString ;
- (BOOL)isStringAvailable;

@end
