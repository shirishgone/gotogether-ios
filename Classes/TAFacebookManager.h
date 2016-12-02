//
//  TAFacebookManager.h
//  TravelApp
//
//  Created by shirish on 23/11/12.
//  Copyright (c) 2012 mutualmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "TAFacebookUser.h"

@interface TAFacebookManager : NSObject

@property (strong, nonatomic) FBSession *session;

+(TAFacebookManager*)sharedInstance;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)isAllow;
- (void)updateFacebookPictureToServerForUser:(User *)user
                                     failure:(void (^)(NSError *error))handleFailure;

// Connection Methods
- (void)connectToFacebookWithHandleSuccess:(void (^)(id successMessage))handleSuccess
                                andFailure:(void (^)(NSError *error))handleFailure ;

- (void)clearSession;
- (void)updateFacebookSession;
//- (void)updateSessionWithSuccessBlock:(void (^)(FBSession *session))handleSuccess
//                         failureBlock:(void (^)(NSError *error))handleFailure;

// GT Updates
- (void)updateUserOnGTServer:(TAFacebookUser *)user;
- (void)updateFriendsOnGTServer;

// Sharing Methods
- (void)shareOnFacebookWithMessage:(NSString *)message;

// Convenience methods
- (BOOL)isFacebookConnected;
+ (NSString *)pictureUrlForUserId:(NSString *)userId;
+ (NSString *)thumnailPictureUrlForUserId:(NSString *)userId;


// All My Friends on facebook
- (void)myFriendsOnFacebookWithSuccess:(void (^)(NSArray *friends))handleSuccess
                          failureBlock:(void (^)(NSError *error))handleError;

// Invite Friends
- (void)inviteFriends:(NSArray *)friendIdsArray
         successBlock:(void (^)(id success))resultBlock
         failureBlock:(void (^)(NSError *error))failureBlock;
- (void)inviteFriendsToApp:(NSArray *)friends
              successBlock:(void (^)(id success))handleSuccess
              failureBlock:(void (^)(NSError *error))handleFailure;

@end
