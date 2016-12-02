//
//  TAFacebookManager.m
//  TravelApp
//
//  Created by shirish on 23/11/12.
//  Copyright (c) 2012 mutualmobile. All rights reserved.
//

#import "TAFacebookManager.h"
#import "goTogetherAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AFHTTPClient.h"
#import "AFXMLRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "XMLReader.h"
#import "TALocationManager.h"
#import "UIImage+TAExtensions.h"
#import "GTAWSManager.h"
#import "GTMutualFriend.h"

#define kFacebookAPI_AppUserUrl @"https://api.facebook.com/method/friends.getAppUsers"
#define kFacebookAPI_inviteFriend @"https://graph.facebook.com/%@/apprequests?access_token=%@"

static TAFacebookManager *sharedInstance = nil;

@interface  TAFacebookManager()
@property (nonatomic, strong)NSArray *readPermissionsArray;
@end

@implementation TAFacebookManager

+(TAFacebookManager*)sharedInstance
{
    @synchronized([TAFacebookManager class])
    {
        if (!sharedInstance){
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
    return nil;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.readPermissionsArray = [NSArray arrayWithObjects:
                                 @"email",
                                 @"public_profile",
                                 @"user_friends",
                                 @"user_about_me",
                                nil];
    return self;
}

- (void)connectToFacebookWithHandleSuccess:(void (^)(id successMessage))handleSuccess
                                andFailure:(void (^)(NSError *error))handleFailure {
    
    if (!self.session.isOpen) {
        // create a fresh session object
        [FBSession
         openActiveSessionWithReadPermissions:self.readPermissionsArray
         allowLoginUI:YES
         completionHandler:^(FBSession *session,
                             FBSessionState status,
                             NSError *error) {

             if (error !=nil) {
                 [self postFacebookConnectedFailedNotificationWithError:error];
                 handleFailure(error);
                 return;
             }
             self.session = session;
             [self fetchProfileDetails];
             handleSuccess(@"Facebook Connected!");
         }];
    }else{
        [self fetchProfileDetails];
        handleSuccess(@"Facebook Connected!");
    }
}

- (void)clearSession {
    [self.session closeAndClearTokenInformation];
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)isAllow {
    return [FBSession
            openActiveSessionWithReadPermissions:self.readPermissionsArray
            allowLoginUI:isAllow
            completionHandler:^(FBSession *session,
                                FBSessionState state,
                                NSError *error) {
                
                self.session = session;
                TALog(@"session: %@",session);
                TALog(@"error: %@",error);
            }];
}

- (void)updateFacebookSession {
    User *currentUser = [User currentUser];
    if (currentUser.facebookId != nil) {
        [FBAppCall handleDidBecomeActive];
        
        id cachedToken = [[NSUserDefaults standardUserDefaults]
                          valueForKey:@"FBAccessTokenInformationKey"];
        TALog(@"cachedToken : %@",cachedToken);
        
        if (cachedToken!= nil) {
            if ([self openSessionWithAllowLoginUI:NO]) {
                [self updateOnGTServer];
            }
        }else{
            if ([self openSessionWithAllowLoginUI:YES]) {
                [self updateOnGTServer];
            }
        }
    }
}

- (void)updateFacebookPictureToServerForUser:(User *)user
                                     failure:(void (^)(NSError *error))handleFailure {
    
    [self downloadFacebookPicForFacebookId:user.facebookId
                                   success:^(UIImage *image) {
                                       [self uploadFacebookPicToAmazon:image
                                                               forUser:user];
                                   } failure:^(NSError *error) {
                                       handleFailure(error);
                                   }];
}

- (void)downloadFacebookPicForFacebookId:(NSString *)facebookId
                                 success:(void (^)(UIImage *image))handleSuccess
                                 failure:(void (^)(NSError *error))handleFailure {

    [UIImage
     startImageDownloadWithUrl:[TAFacebookManager pictureUrlForUserId:facebookId]
     success:^(UIImage *image) {
         handleSuccess(image);
     } failure:^(NSError *error) {
         handleFailure(error);
     }];
}

- (void)uploadFacebookPicToAmazon:(UIImage *)image forUser:(User *)user {
    [[GTAWSManager sharedInstance]
     uploadImageToServer:image
     withName:user.userId];
}

- (void)fetchProfileDetails {
    // Fetch Profile details.
    [[TAFacebookManager sharedInstance]
     fetchfacebookMyProfile:^(TAFacebookUser *facebookUser) {
         [self postFacebookConnectedNotificationWith:facebookUser];
     } failureBlock:^(NSError *error) {
         [self postFacebookConnectedFailedNotificationWithError:error];
     }];
}


- (void)updateOnGTServer {
    [self updateFacebookTokenOnServer:self.session];
    [self updateFriendsOnGTServer];
}

- (void)updateFacebookTokenOnServer:(FBSession *)session {
    TALog(@"Facebook Session: %@",session.accessTokenData.accessToken);
    
    if (session != nil) {
        [User updateFacebookAccessToken:session.accessTokenData.accessToken
                             sucess:^(NSString *sucessMessage) {
                                 
                             } failure:^(NSError *error) {
                                 
                             }];        
    }
}


- (void)updateFriendsOnGTServer {
    [self friendsSubscribedForGoTogether:^(NSMutableString *userIDString) {
        
        if ([userIDString length] > 0) {
            [User
             updateFacebookFriends:userIDString
             sucess:^(NSString *sucessMessage) {
                 TALog(@"update facebook friends: %@",sucessMessage);
             } failure:^(NSError *error) {
                 TALog(@"error: %@",error);
             }];
        }
    } failureBlock:^(NSError *error) {
        TALog(@"error: %@",error);
    }];
}

- (void)updateUserOnGTServer:(TAFacebookUser *)user{

    [User
     updateFacebookDetails:user
     sucess:^(NSString *sucessMessage) {
         TALog(@"SUCCESS %s",__PRETTY_FUNCTION__);
         
     } failure:^(NSError *error) {
         TALog(@"ERROR  %s",__PRETTY_FUNCTION__);
     }];
}

- (void)fetchfacebookMyProfile:(void (^)(TAFacebookUser *facebookUser))resultBlock
                  failureBlock:(void (^)(NSError *error))failureBlock {

    [FBRequestConnection
     startForMeWithCompletionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {

        if (result == nil) {
            failureBlock(error);
        }
         
        TALog(@"facebook user details: %@",result);
        
         NSString *gender = [result objectForKey:@"gender"];
         NSString *facebookId = [result valueForKey:@"id"];
         NSString *facebookEmail = [result valueForKey:@"email"];
         NSString *name = [result valueForKey:@"name"];
         NSString *dateOfBirth = [result valueForKey:@"birthday"];
         NSString *description = [result valueForKey:@"bio"];
         NSString *profileUrl = [result valueForKey:@"link"];
         
        TAFacebookUser *facebookDetails = [[TAFacebookUser alloc] init];
        [facebookDetails setFacebookID:facebookId];
        
        if (facebookEmail !=nil) {
            [facebookDetails setEmailId:facebookEmail];
        }else {
            NSMutableString *email = [[NSMutableString alloc] init];
            [email appendString:facebookId];
            [email appendString:@"@facebook.com"];
            [facebookDetails setEmailId:email];
        }
         
        if (gender !=nil) {
            [facebookDetails setGender:gender];
        }
         
        if (name !=nil) {
            [facebookDetails setFullName:name];
        }
         
         if (profileUrl != nil) {
             [facebookDetails setProfileUrl:profileUrl];
         }
         
         if (description != nil) {
             [facebookDetails setProfileDescription:description];
         }
         if (dateOfBirth !=nil) {
             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
             [dateFormatter setDateFormat:@"mm/dd/yyyy"];
             NSDate *date = [dateFormatter dateFromString:dateOfBirth];
             [facebookDetails setDateOfBirth:date];
         }
         
         facebookDetails.facebookAccessToken = self.session.accessTokenData.accessToken;
         
        resultBlock(facebookDetails);
    }];
}

- (void)inviteFriendsToApp:(NSArray *)friends
              successBlock:(void (^)(id success))handleSuccess
              failureBlock:(void (^)(NSError *error))handleFailure
{
    //TODO: Invite friends can be done by facebook messages from V2.x API

    User *currentUser = [User currentUser];
    NSString *messageString = [NSString stringWithFormat:@"%@ has invited you to use gotogether.",currentUser.name];
    NSMutableString *friendIds = [[NSMutableString alloc] init];
    for (id <FBGraphUser> friend in friends) {
        [friendIds appendString:[friend id]];
        if([friends lastObject] != friend){
            [friendIds appendString:@","];
        }
    }
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   friendIds, @"to",
                                   nil];
    
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:messageString
     title:@"gotogether"
     parameters:params
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Case A: Error launching the dialog or sending request.
             TALog(@"Error sending request.");
             handleFailure(error);
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 handleFailure(error);
                 TALog(@"User canceled request.");
             } else {
                 TALog(@"Request Sent.");
                 handleSuccess(@"Request sent!");
             }
         }}
     friendCache:nil];
}

- (void)inviteFriends:(NSArray *)friendIdsArray
         successBlock:(void (^)(id success))resultBlock
         failureBlock:(void (^)(NSError *error))failureBlock {
    
    NSString *friendIdsString = @"";
    NSString *graphUrlStrng = [NSString stringWithFormat:@"https://graph.facebook.com/%@/apprequests?access_token=%@",
                               friendIdsString,
                               [self.session.accessTokenData accessToken]];
    
    NSURL *graphUrl = [NSURL URLWithString:graphUrlStrng];
    NSURLRequest *graphUrlRequest = [NSURLRequest requestWithURL:graphUrl];
    
    [NSURLConnection
     sendAsynchronousRequest:graphUrlRequest
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
         
         TALog(@"response: %@",response);
         TALog(@"data: %@",data);
         TALog(@"error: %@",error);
     }];
}

- (void)myFriendsOnFacebookWithSuccess:(void (^)(NSArray *friends))handleSuccess
                          failureBlock:(void (^)(NSError *error))handleError{

    NSMutableArray *friendsArray = [NSMutableArray array];
    FBRequest *request = [FBRequest requestForMyFriends];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if (!error) {
            NSArray* friends = [result objectForKey:@"data"];
            TALog(@"Found: %i friends", friends.count);
            for (NSDictionary<FBGraphUser>* friend in friends) {
                TALog(@"I have a friend named %@ with id %@", friend.name, friend.id);
                [friendsArray addObject:friend];
            }
            handleSuccess(friendsArray);
        }else{
            handleError(error);
        }
    }];
}

- (void)friendsSubscribedForGoTogether:(void (^)(NSMutableString *userIDString))resultBlock
                          failureBlock:(void (^)(NSError *error))failureBlock {
    
    if (self.session.state != FBSessionStateOpen) {
        failureBlock(nil);
    }
    
    NSMutableString *friendsUserId = [NSMutableString string];
    NSString *graphUrlStrng = [NSString stringWithFormat:@"%@?access_token=%@",
                               kFacebookAPI_AppUserUrl,[self.session.accessTokenData accessToken]];
    
    NSURL *graphUrl = [NSURL URLWithString:graphUrlStrng];
    NSURLRequest *graphUrlRequest = [NSURLRequest requestWithURL:graphUrl];
    [NSURLConnection sendAsynchronousRequest:graphUrlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        NSDictionary *xmlDIct = [XMLReader dictionaryForXMLData:data error:&error];
        
        if (!error) {
            NSDictionary *friendsUsingAppDictionary = [xmlDIct objectForKey:@"friends_getAppUsers_response"];
            if ([friendsUsingAppDictionary.allKeys containsObject:@"uid"]) {
                id userIds = [friendsUsingAppDictionary objectForKey:@"uid"];
                
                if ([userIds isKindOfClass:[NSArray class]]) {
                    NSArray *userIdsArray = (NSArray *)userIds;
                    for (int i =0; i < [userIdsArray count]; i++) {
                        NSDictionary *userIdDict = [userIdsArray objectAtIndex:i];
                        NSString *userID = [[[userIdDict objectForKey:@"text"]
                                             stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]
                                            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        
                        if (i != [userIdsArray count] -1) {
                            [friendsUserId appendString:[NSString stringWithFormat:@"%@,",userID]];
                        }
                        else {
                            [friendsUserId appendString:[NSString stringWithFormat:@"%@",userID]];
                        }
                    }
                }else{
                    NSString *userIdsString = [userIds objectForKey:@"text"];
                    if (userIdsString !=nil) {
                        [friendsUserId appendString:[[userIdsString
                                                      stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]
                                                     stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                    }
                }
            }

            resultBlock(friendsUserId);
        }
        else {
            failureBlock (error);
        }
        }];
}

#pragma mark - Notification Methods

- (void)postFacebookConnectedNotificationWith:(TAFacebookUser *)facebookUser {
    
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:facebookUser
                 forKey:kFacebookConnected_sendObject];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNotificationType_facebookConnected
     object:nil
     userInfo:userInfo];
}


- (void)postFacebookConnectedFailedNotificationWithError:(NSError *)error {
    
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:error
                 forKey:kFacebookFailed_sendObject];

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNotificationType_facebookConnectFailed
     object:nil
     userInfo:userInfo];
}

#pragma mark - Convenience methods
- (BOOL)isFacebookConnected {
    User *currentUser = [User currentUser];
    if(currentUser.facebookId!=nil){
        return YES;
    }else{
        return NO;
    }
}

+ (NSString *)pictureUrlForUserId:(NSString *)userId{
    return [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large",userId];
}

+ (NSString *)thumnailPictureUrlForUserId:(NSString *)userId{
    return [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=small",userId];
}


#pragma mark - Post to Facebook Wall methods
- (void)reauthorizeFacebookPost:(void (^)(FBSession *session))handleSuccessBlock
                   failureBlock:(void (^)(NSError *error))handleFailureBlock
{
    
    if ([self.session.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        
        [self.session
         requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
         defaultAudience:FBSessionDefaultAudienceFriends
         completionHandler:^(FBSession *session, NSError *error) {
             if (!error) {
                 handleSuccessBlock(session);
             }else{
                 handleFailureBlock(error);
             }
         }];
    } else {
        handleSuccessBlock(self.session);
    }
}

- (void)shareOnFacebookWithMessage:(NSString *)message{

    if ([[FBSession activeSession] isOpen] == NO) {

        [self reauthorizeFacebookPost:^(FBSession *session) {
            [self presentFeedDialogWithMessage:message];
        } failureBlock:^(NSError *error) {
            
        }];
    }else{
        [self presentFeedDialogWithMessage:message];
    }
}

- (void)presentFeedDialogWithMessage:(NSString *)message{
    
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    [params setName:@"gotogether"];
    [params setCaption:@"Intercity ride-sharing app."];
    [params setLink:[NSURL URLWithString:@"http:gotogether.mobi"]];

    [FBDialogs
     presentShareDialogWithParams:params
     clientState:nil
     handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
     }];
}

- (void)postWithParams:(NSDictionary *)params{
    [FBRequestConnection
     startWithGraphPath:@"me/feed"
     parameters:params
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
         TALog(@"results: %@",result);
         TALog(@"error: %@",error);
     }];
    
}

#pragma mark -
#pragma mark Facebook Login Code
+ (NSString *)FBErrorCodeDescription:(FBErrorCode) code {
    switch(code){
        case FBErrorInvalid :{
            return @"FBErrorInvalid";
        }
        case FBErrorOperationCancelled:{
            return @"FBErrorOperationCancelled";
        }
        case FBErrorLoginFailedOrCancelled:{
            return @"FBErrorLoginFailedOrCancelled";
        }
        case FBErrorRequestConnectionApi:{
            return @"FBErrorRequestConnectionApi";
        }case FBErrorProtocolMismatch:{
            return @"FBErrorProtocolMismatch";
        }
        case FBErrorHTTPError:{
            return @"FBErrorHTTPError";
        }
        case FBErrorNonTextMimeTypeReturned:{
            return @"FBErrorNonTextMimeTypeReturned";
        }        default:
            return @"[Unknown]";
    }
}
@end

