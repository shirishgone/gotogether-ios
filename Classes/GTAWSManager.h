//
//  GTAWSManager.h
//  goTogether
//
//  Created by shirish on 17/05/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTAWSManager : NSObject
+ (GTAWSManager*)sharedInstance;
- (void)uploadImage:(UIImage *)image
          forUserId:(NSString *)userId
             sucess:(void (^)(id response))handleSuccess
            failure:(void (^)(NSError *error))handleFailure;

- (void)lastUpdatedDateOfUserProfilePicWithUserId:(NSString *)userId
        sucess:(void (^)(NSDate *lastUpdatedDate))handleSuccess
        failure:(void (^)(NSError *error))handleFailure;


- (void)imageUrlForUserId:(NSString *)userId
                   sucess:(void (^)(NSString *imageUrlString))handleSuccess
                  failure:(void (^)(NSError *error))handleFailure;

- (void)uploadImageToServer:(UIImage *)image
                   withName:(NSString *)name;

@end
