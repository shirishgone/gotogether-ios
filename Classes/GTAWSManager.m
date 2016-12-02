//
//  GTAWSManager.m
//  goTogether
//
//  Created by shirish on 17/05/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTAWSManager.h"
#import "Constants.h"
#import <AWSRuntime/AWSRuntime.h>
#import <AWSS3/AWSS3.h>

static GTAWSManager *sharedInstance = nil;

@interface GTAWSManager()

@property (nonatomic, retain) AmazonS3Client *s3;
@property (nonatomic, copy) UIImage *image;

@end

@implementation GTAWSManager

+(GTAWSManager*)sharedInstance
{
    @synchronized([GTAWSManager class])
    {
        if (!sharedInstance){
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
    return nil;
}


- (id)init{
    if (self = [super init]) {
        [self setupS3];
    }
    return self;
}

- (void)setupS3{

    // Initial the S3 Client.
    self.s3 = [[AmazonS3Client alloc] initWithAccessKey:ACCESS_KEY_ID withSecretKey:SECRET_KEY];
    self.s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
}

- (void)uploadImage:(UIImage *)image
          forUserId:(NSString *)userId
             sucess:(void (^)(id response))handleSuccess
            failure:(void (^)(NSError *error))handleFailure

{
    NSData *imageData = UIImagePNGRepresentation(image);

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // Upload image data.  Remember to set the content type.
        S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:userId
                                                                 inBucket:[Constants pictureBucket]];
        por.contentType = @"image/png";
        por.data        = imageData;
        
        // Put the image data into the specified s3 bucket and object.
        S3PutObjectResponse *putObjectResponse = [self.s3 putObject:por];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(putObjectResponse.error != nil)
            {
                TALog(@"Error: %@", putObjectResponse.error);
                handleFailure(putObjectResponse.error);
            }
            else
            {
                handleSuccess(@"Saved Sucessfully");
            }            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
    });
}

- (void)lastUpdatedDateOfUserProfilePicWithUserId:(NSString *)userId
        sucess:(void (^)(NSDate *lastUpdatedDate))handleSuccess
        failure:(void (^)(NSError *error))handleFailure{

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        //TODO: Crashes here.
        S3GetObjectMetadataRequest *getMetadataRequest = [[S3GetObjectMetadataRequest alloc] initWithKey:userId withBucket:[Constants pictureBucket]];
        if (getMetadataRequest != nil) {
            S3GetObjectMetadataResponse *getMetadataResponse = [self.s3 getObjectMetadata:getMetadataRequest];
            if (getMetadataResponse.lastModified!=nil) {
                handleSuccess(getMetadataResponse.lastModified);
            }else{
                handleFailure(nil);
            }
        }else{
            handleFailure(nil);
        }
    });
}

- (void)imageUrlForUserId:(NSString *)userId
                   sucess:(void (^)(NSString *imageUrlString))handleSuccess
                  failure:(void (^)(NSError *error))handleFailure

{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // Set the content type so that the browser will treat the URL as an image.
        S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
        override.contentType = @"image/png";
        
        // Request a pre-signed URL to picture that has been uplaoded.
        S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
        gpsur.key                     = userId;
        gpsur.bucket                  = [Constants pictureBucket];
        gpsur.expires                 = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 3600]; // Added an hour's worth of seconds to the current time.
        gpsur.responseHeaderOverrides = override;
        
        // Get the URL
        NSError *error;
        NSURL *url = [self.s3 getPreSignedURL:gpsur error:&error];
        
        if(url == nil)
        {
            handleFailure(error);
        }
        else
        {
            handleSuccess(url.absoluteString);
        }        
    });
}

- (void)uploadImageToServer:(UIImage *)image
                   withName:(NSString *)name {
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    UIImage *imageToUpload = [UIImage imageWithData:imageData scale:1.0];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,(unsigned long)NULL)
                   , ^{
                       [[GTAWSManager sharedInstance]
                        uploadImage:imageToUpload
                        forUserId:name
                        sucess:^(id response) {
                        } failure:^(NSError *error) {
                        }];
                       
                   });
}

@end
