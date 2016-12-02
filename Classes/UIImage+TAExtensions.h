//
//  UIImage+TAExtensions.h
//  goTogether
//
//  Created by shirish on 27/02/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (TAExtensions)

+ (void)startImageDownloadWithUrl:(NSString *)imageUrlString
                          success:(void (^)(UIImage *image))success
                          failure:(void (^)(NSError *error))handleFailure;

+ (NSString *)saveImage:(UIImage *)image
               withName:(NSString *)name;

+ (void)downloadImageForUserId:(NSString *)userId
                       success:(void (^)(UIImage *image))success
                       failure:(void (^)(NSError *error))handleFailure;
+ (void)downloadFacebookImageForFacebookId:(NSString *)facebookId
                                   success:(void (^)(UIImage *image))success
                                   failure:(void (^)(NSError *error))handleFailure;


+ (BOOL)isAvailableLocallyForUserId:(NSString *)userId;
+ (void)updateImageForUserId:(NSString *)userId
                     success:(void (^)(UIImage *image))success
                     failure:(void (^)(NSError *error))handleFailure;

+ (NSString *)filePathForUserId:(NSString *)userId;
- (UIImage *)fixOrientation;
+ (UIImage *)mergeImagesWithTopImage:(UIImage *)image bottomImage:(UIImage *)borderImage;
+ (UIImage *)blurImage:(UIImage *)image;

+ (BOOL)isImageAvailableInCacheForUserId:(NSString *)userId;
+ (void)cacheImage:(UIImage *)image forUserId:(NSString *)userId ;
+ (UIImage *)cachedImageforUserId:(NSString *)userId ;

@end
