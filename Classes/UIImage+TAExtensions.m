//
//  UIImage+TAExtensions.m
//  goTogether
//
//  Created by shirish on 27/02/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "UIImage+TAExtensions.h"
#import "AFImageRequestOperation.h"
#import "User.h"
#import "GTAWSManager.h"
#include <CoreImage/CoreImage.h>
#import "TAFAcebookManager.h"

int const kPercentageOffset = 10;
@implementation UIImage (TAExtensions)

+ (void)startImageDownloadWithUrl:(NSString *)imageUrlString
                          success:(void (^)(UIImage *image))success
                          failure:(void (^)(NSError *error))handleFailure{
    

    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrlString]];
    AFImageRequestOperation *imageOperation =
    [AFImageRequestOperation
     imageRequestOperationWithRequest:imageRequest
     success:^(UIImage *image) {
         if (image !=nil) {
             success(image);
         }else{
             handleFailure(nil);
         }
     }];
    
    [imageOperation start];
}

+ (NSString *)saveImage:(UIImage *)image
               withName:(NSString *)name {

    [UIImage cacheImage:image forUserId:name];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths.count > 0) {
        NSData *pngData = UIImagePNGRepresentation(image);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"%@.png",name]];
        [pngData writeToFile:filePath atomically:YES];
        return filePath;
    }
    return nil;
}

+ (void)downloadImageForUserId:(NSString *)userId
                       success:(void (^)(UIImage *image))success
                       failure:(void (^)(NSError *error))handleFailure {
    
    GTAWSManager *awsManager = [GTAWSManager sharedInstance];
  
    [awsManager
     imageUrlForUserId:userId
     sucess:^(NSString *imageUrlString) {
         [UIImage startImageDownloadWithUrl:imageUrlString
                                    success:^(UIImage *image) {
                                             
                                        [awsManager
                                         lastUpdatedDateOfUserProfilePicWithUserId:userId
                                         sucess:^(NSDate *lastUpdatedDate) {
                                             [self saveModifiedDate:lastUpdatedDate forUserId:userId];
                                         }failure:^(NSError *error) {
                                         }];

                                        [self cacheImage:image forUserId:userId];
                                        [UIImage saveImage:image withName:userId];
                                        success(image);
                                    } failure:^(NSError *error) {
                                        handleFailure(error);
                                    }];

     } failure:^(NSError *error) {
         handleFailure(error);
     }];
    
    TALog(@"************************IMAGE FETCH FROM SERVER*******************************");
}

+ (void)downloadFacebookImageForFacebookId:(NSString *)facebookId
                               success:(void (^)(UIImage *image))success
                               failure:(void (^)(NSError *error))handleFailure {
    
    NSString *pictureUrlString = [TAFacebookManager thumnailPictureUrlForUserId:facebookId];
    [UIImage startImageDownloadWithUrl:pictureUrlString
                               success:^(UIImage *image) {
                                   //TODO: Cache image.
                                   success(image);
                               } failure:^(NSError *error) {
                                   handleFailure(error);
                               }];
    
    
    TALog(@"************************IMAGE FETCH FROM SERVER*******************************");
}

+ (void)cacheImage:(UIImage *)image forUserId:(NSString *)userId {
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.rootViewController.imageCache setObject:image forKey:userId];
}

+ (UIImage *)cachedImageforUserId:(NSString *)userId {
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    return [appDelegate.rootViewController.imageCache objectForKey:userId];
}

+ (BOOL)isImageAvailableInCacheForUserId:(NSString *)userId {
    UIImage *image = [self cachedImageforUserId:userId];
    if (image!=nil) {
        TALog(@"************************CACHED IMAGE*******************************");
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)isAvailableLocallyForUserId:(NSString *)userId {

    BOOL isAvailable = NO;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths.count > 0) {
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"%@.png",userId]];
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        isAvailable = fileExists;

    }
    return isAvailable;
}


+ (NSString *)filePathForLastModifiedPlistFile {
    return [[NSBundle mainBundle] pathForResource:@"ImageCacheModifiedDates" ofType:@"plist"];
}

+ (NSDate *)modifiedDateForPictureOnDiskForUserId:(NSString *)userId {
    User *user = [User userForUserId:userId];
    if (user!=nil) {
        return  user.pictureLastModified;
    }else{
        return nil;
    }

}

+ (void)saveModifiedDate:(NSDate *)modifiedDate forUserId:(NSString *)userId {
    User *user = [User userForUserId:userId];
    if (user) {
        [user setPictureLastModified:modifiedDate];
    }
    [[NSManagedObjectContext MR_defaultContext] saveToPersistentStoreWithCompletion:nil];
}


+ (void)updateImageForUserId:(NSString *)userId
                     success:(void (^)(UIImage *image))success
                     failure:(void (^)(NSError *error))handleFailure {
    
    // Check if last modified date is same as stored image's last modified date.
    //Download only if changed.
    
    GTAWSManager *awsManager = [GTAWSManager sharedInstance];
    [awsManager
     lastUpdatedDateOfUserProfilePicWithUserId:userId
     sucess:^(NSDate *lastUpdatedDate) {
         
         NSDate *lastModifiedDateOfexistingImage = [self modifiedDateForPictureOnDiskForUserId:userId];
         BOOL shouldDownload = NO;
         if (lastModifiedDateOfexistingImage !=nil) {
             if ( ([lastModifiedDateOfexistingImage compare:lastUpdatedDate]) == NSOrderedSame ) {
                 shouldDownload = NO;
             }else{
                 shouldDownload = YES;
             }
             
         }else{
             shouldDownload = YES;
         }
         if (shouldDownload) {
             [self downloadImageForUserId:userId
                                  success:^(UIImage *image) {
                                      [UIImage saveImage:image withName:userId];
                                      success(image);
                                  } failure:^(NSError *error) {
                                      handleFailure(error);
                                  }];
             
         }else {
             handleFailure(nil);
         }

     } failure:^(NSError *error) {
         handleFailure(error);
    }];
}

+ (NSString *)filePathForUserId:(NSString *)userId{
    NSString *imageUrlString = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths.count > 0) {
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"%@.png",userId]];
        
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (fileExists) {
            imageUrlString = filePath;
        }
    }
    return imageUrlString;
}

- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage *)mergeImagesWithTopImage:(UIImage *)image bottomImage:(UIImage *)borderImage{

    CGSize size = borderImage.size;

    float offset = size.width * kPercentageOffset/100;
    float width = size.width - 2*offset;
    double ratio = image.size.width/width;
    //float height = image.size.height/ratio;
    
    UIImage *scaledImage = [UIImage imageWithCGImage:[image CGImage]
                                               scale:ratio
                                         orientation:(image.imageOrientation)];
    UIGraphicsBeginImageContext(size);
    [borderImage drawInRect:CGRectMake( 0, 0, size.width, size.height)];
    [scaledImage drawInRect:CGRectMake( offset, offset, width, width)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

+ (UIImage *)blurImage:(UIImage *)image{
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [[CIImage alloc] initWithImage:image];
    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [blurFilter setDefaults];
    [blurFilter setValue:inputImage forKey:@"inputImage"];
    CGFloat blurLevel = 4.0f;          // Set blur level
    [blurFilter setValue:[NSNumber numberWithFloat:blurLevel] forKey:@"inputRadius"];    // set value for blur level
    CIImage *outputImage = [blurFilter valueForKey:@"outputImage"];
    CGRect rect = inputImage.extent;    // Create Rect
    rect.origin.x += blurLevel;         // and set custom params
    rect.origin.y += blurLevel;         //
    rect.size.height -= blurLevel*2.0f; //
    rect.size.width -= blurLevel*2.0f;  //
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:rect];    // Then apply new rect
    UIImage *result = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return result;
}

@end
