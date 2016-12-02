#import "User.h"
#import "AFHTTPRequestOperation.h"
#import "goTogetherAppDelegate.h"
#import "AFJSONRequestOperation.h"
#import "TAFacebookManager.h"
#import "Event.h"
#import "TALocationManager.h"
#import "Comment.h"
#import "NSManagedObject+MagicalRecord.h"
#import "AFHTTPClient.h"
#import "CoreData+MagicalRecord.h"
#import "MMHTTPClient.h"
#import "UIImage+TAExtensions.h"
#import "GTAnalyticsManager.h"
#import <CoreLocation/CLLocation.h>


@interface User ()
// Private interface goes here.
@end

@implementation User

// Custom logic goes here.

+ (void)loginWithFacebook:(User *)user
            facebookToken:(NSString *)facebookToken
                   sucess:(void (^)(void))handleSuccess
                  failure:(void (^)(NSError *error))handleFailure {
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:user.userId forKey:@"email"];
    [parameters setObject:user.facebookId forKey:@"facebookid"];
    [parameters setObject:facebookToken forKey:@"fb_token"];
    
    if (user.dateOfBirth) {
        NSDate *dateOfBirth = user.dateOfBirth;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"mm/dd/yyyy"];
        NSString *dateOfBirthString = [dateFormatter stringFromDate:dateOfBirth];
        [parameters setObject:dateOfBirthString forKey:@"date_of_birth"];
    }

    if (user.name) {
        [parameters setObject:user.name forKey:@"name"];
    }
    if (user.gender) {
        [parameters setObject:user.gender forKey:@"gender"];
    }
    
    if (user.profileDescription) {
        [parameters setObject:user.profileDescription forKey:@"profile_description"];
    }
    if (user.facebookProfileLink) {
        [parameters setObject:user.facebookProfileLink forKey:@"facebook_profile_url"];
    }
    
    
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_loginWithFacebook]
                       parameters:parameters];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSError *jsonError = nil;
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             id error = [jsonDictionary valueForKey:@"error"];
             //NSDictionary *resultDict = [jsonDictionary valueForKey:@"result"];
             
             if ([MMHTTPClient isError:error]) {
                 jsonError = [MMHTTPClient errorObject:error];
                 handleFailure(jsonError);
                 return;
             }else{
                 NSString *userId = user.userId;
                 NSString *token = [[jsonDictionary valueForKey:@"result"] valueForKey:@"token"];
                 
                 
                 if (token !=nil) {
                     [User setFacebookLoggedIn];
                     [User saveUserIdToUserDefaults:userId];

                     User *existingUser = [User userForUserId:userId];

                     if (existingUser == nil) {
                         [User saveUser:user andAccessToken:token];
                     }else{
                         [User saveUser:existingUser andAccessToken:token];
                     }
                     
                     [[NSNotificationCenter defaultCenter]
                      postNotificationName:kNotificationType_loginSuccessful
                      object:nil];
                     
                     handleSuccess();
                 }
             }
         }else{
             handleFailure(nil);
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];
}


+ (void)registerUser:(User *)user
              sucess:(void (^)(NSString *successMessage))handleSuccess
             failure:(void (^)(NSError *error))handleFailure{
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:user.userId forKey:@"email"];
    [parameters setObject:user.name forKey:@"name"];
    [parameters setObject:user.password forKey:@"password"];
    [parameters setObject:user.gender forKey:@"gender"];
    
    if (user.facebookId != nil) {
        [parameters setObject:user.facebookId forKey:@"facebookid"];
    }
        
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_register]
                       parameters:parameters];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSError *jsonError = nil;
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             id error = [jsonDictionary valueForKey:@"error"];
             //NSDictionary *resultDict = [jsonDictionary valueForKey:@"result"];

             if ([MMHTTPClient isError:error]) {
                 jsonError = [MMHTTPClient errorObject:error];
                 handleFailure(jsonError);
                 return;
             }else{
                 
                 NSString *successMessage = @"Thanks for Registering. Please verify your email before logging in.";
                 handleSuccess(successMessage);
             }
         }else {
             NSString *errorDescription = @"Error: JSON is not a dictionary.";
             NSInteger errorCode = 2000;
             NSString *domain = @"API";
             jsonError = [NSError errorWithDomain:domain
                                             code:errorCode
                                         userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:@"errorDescription"]];
             handleFailure(jsonError);
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];
}

+ (BOOL)isPhoneVerified {
    User *currentUser = [User currentUser];
    return currentUser.phoneNumberVerifiedValue;
}

+ (void)sendPinToPhoneNumber:(NSString *)phoneNumber
                     Success:(void (^)(id success))handleSuccess
                     failure:(void (^)(NSError *error))handleFailure{
    
    User *user = [User currentUser];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (user.userId != nil) {
        [parameters setObject:user.userId forKey:@"userid"];
    }
    if (user.accessToken != nil) {
        [parameters setObject:user.accessToken forKey:@"access_token"];
    }
    if (phoneNumber !=nil) {
        [parameters setObject:phoneNumber forKey:@"mobile_number"];
    }
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                     path:[NSString stringWithFormat:@"%@",kRedHotApi_sendPin]
                                               parameters:parameters];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSError *jsonError = nil;
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             id error = [jsonDictionary valueForKey:@"error"];
             
             if ([MMHTTPClient isError:error]) {
                 NSError *errorObject = [MMHTTPClient errorObject:error];
                 handleFailure(errorObject);
                 return;
             }
             
             [user setMobile:phoneNumber];
             NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
             [defaultContext saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                 TALog(@"sucess: %d",success);
             }];
             
             NSString *successMessage = @"A Pin has been sent to your mobile!";
             handleSuccess(successMessage);
             return;
         }else{
             
             NSString *errorDescription = @"JSON is not a dictionary";
             NSInteger errorCode = 2000;
             NSString *domain = @"GoTogetherClient";
             
             jsonError = [NSError errorWithDomain:domain
                                             code:errorCode
                                         userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:@"errorDescription"]];
             handleFailure(jsonError);
             return;
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];
}


+ (void)logoutUserForSuccess:(void (^)(NSString *sucessMessage))handleSuccess
                     failure:(void (^)(NSError *error))handleFailure{

    User *user = [User currentUser];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (user.userId != nil) {
        [params setObject:user.userId forKey:@"userid"];
    }
    if (user.accessToken != nil) {
        [params setObject:user.accessToken forKey:@"access_token"];
    }

    NSURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                     path:[NSString stringWithFormat:@"%@",kRedHotApi_logoutUser]
                                               parameters:params];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSError *jsonError = nil;
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             id error = [jsonDictionary valueForKey:@"error"];
             
             if ([MMHTTPClient isError:error]) {
                 handleFailure(error);
                 return;
             }
             
             NSString *successMessage = @"Successfully loggedout!";
             handleSuccess(successMessage);
             return;
         }else{
             
             NSString *errorDescription = @"JSON is not a dictionary";
             NSInteger errorCode = 2000;
             NSString *domain = @"GoTogetherClient";
             
             jsonError = [NSError errorWithDomain:domain
                                             code:errorCode
                                         userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:@"errorDescription"]];
             handleFailure(jsonError);
             return;
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];
}

+ (void)forgotPasswordForEmailId:(NSString *)emailId
                         success:(void (^)(NSString *sucessMessage))handleSuccess
                         failure:(void (^)(NSError *error))handleFailure{
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:emailId forKey:@"userid"];
    
    NSURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                     path:[NSString stringWithFormat:@"%@",kRedHotApi_forgotPassword]
                                               parameters:parameters];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSError *jsonError = nil;
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             id error = [jsonDictionary valueForKey:@"error"];
             
             if ([MMHTTPClient isError:error]) {
                 handleFailure(error);
                 return;
             }
             
             NSString *successMessage = @"Your Account Credentials are sent to your email!";
             handleSuccess(successMessage);
             return;
         }else{
             
             NSString *errorDescription = @"JSON is not a dictionary";
             NSInteger errorCode = 2000;
             NSString *domain = @"GoTogetherClient";
             
             jsonError = [NSError errorWithDomain:domain
                                             code:errorCode
                                         userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:@"errorDescription"]];
             handleFailure(jsonError);
             return;
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];

}

+ (void)updateUserLocation:(CLLocation *)location {
    User *user = [User currentUser];
    if (user.userId == nil) {
        return;
    }

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (user.userId != nil) {
        [parameters setObject:user.userId forKey:@"userid"];
    }
    if (user.accessToken != nil) {
        [parameters setObject:user.accessToken forKey:@"access_token"];
    }
    CLLocationCoordinate2D coordinate =  location.coordinate;
    if (location != nil && coordinate.latitude != 0.0 && coordinate.longitude !=0.0) {
        [parameters setObject:[NSNumber numberWithDouble:coordinate.latitude] forKey:@"current_lat"];
        [parameters setObject:[NSNumber numberWithDouble:coordinate.longitude] forKey:@"current_lon"];
        
    }
    
    NSURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                     path:[NSString stringWithFormat:@"%@",kRedHotApi_updateUser]
                                               parameters:parameters];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             id error = [jsonDictionary valueForKey:@"error"];
             
             if ([MMHTTPClient isError:error]) {

                 TALog(@"location update failed.");
                 return;
             }
             TALog(@"location updated on server.");
             return;
             
         }else{
             TALog(@"location update failed.");
             return;
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         TALog(@"location update failed.");
     }];
    [operation start];
}

+ (void)updateUserPushToken:(NSString *)pushToken
                     sucess:(void (^)(NSString *sucessMessage))handleSuccess
                    failure:(void (^)(NSError *error))handleFailure{
    
    User *user = [User currentUser];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableDictionary *editUserParameters = [NSMutableDictionary dictionary];
    if (user.userId != nil) {
        [editUserParameters setObject:user.userId forKey:@"userid"];
    }
    if (user.accessToken != nil) {
        [editUserParameters setObject:user.accessToken forKey:@"access_token"];
    }
    if (pushToken != nil) {
        [editUserParameters setObject:pushToken forKey:@"push_token"];
    }else {
        handleFailure(nil);
    }
    
    NSURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                     path:[NSString stringWithFormat:@"%@",kRedHotApi_updateUser]
                                               parameters:editUserParameters];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSError *jsonError = nil;
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             id error = [jsonDictionary valueForKey:@"error"];
             
             if ([MMHTTPClient isError:error]) {
                 handleFailure(error);
                 return;
             }
             
             NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
             [defaultContext MR_saveToPersistentStoreWithCompletion:nil];
             
             NSString *successMessage = @"User updated!";
             handleSuccess(successMessage);
             return;
         }else{
             
             NSString *errorDescription = @"JSON is not a dictionary";
             NSInteger errorCode = 2000;
             NSString *domain = @"GoTogetherClient";
             
             jsonError = [NSError errorWithDomain:domain
                                             code:errorCode
                                         userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:@"errorDescription"]];
             handleFailure(jsonError);
             return;
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];
}

+ (void)updateFacebookDetails:(TAFacebookUser *)facebookUser
                       sucess:(void (^)(NSString *sucessMessage))handleSuccess
                      failure:(void (^)(NSError *error))handleFailure{
    
    User *user = [User currentUser];
    if (user == nil || facebookUser.facebookID == nil) {
        handleFailure(nil);
    }

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (user.userId != nil) {
        [parameters setObject:user.userId forKey:@"userid"];
    }
    if (user.accessToken != nil ) {
        [parameters setObject:user.accessToken forKey:@"access_token"];
    }

    // Facebook details
    if (user.facebookId == nil & facebookUser.facebookID !=nil) {
        [user setFacebookId:facebookUser.facebookID];
        [parameters setObject:facebookUser.facebookID forKey:@"facebookid"];
    }
    if (user.name == nil & facebookUser.fullName !=nil) {
        [user setName:facebookUser.fullName];
        [parameters setObject:facebookUser.fullName forKey:@"name"];
    }
    if (user.gender == nil & facebookUser.gender !=nil) {
        [user setGender:facebookUser.gender];
        [parameters setObject:facebookUser.gender forKey:@"gender"];
    }

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    
    NSURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                     path:[NSString stringWithFormat:@"%@",kRedHotApi_updateUser]
                                               parameters:parameters];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSError *jsonError = nil;
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             id error = [jsonDictionary valueForKey:@"error"];
             
             if ([MMHTTPClient isError:error]) {
                 handleFailure(error);
                 return;
             }
             
             [[NSNotificationCenter defaultCenter]
              postNotificationName:kNotificationType_facebookDetailsUpdatedOnGT
              object:nil];

             NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
             [defaultContext MR_saveToPersistentStoreWithCompletion:nil];
             
             NSString *successMessage = @"User updated!";
             handleSuccess(successMessage);
             return;
         }else{
             
             NSString *errorDescription = @"JSON is not a dictionary";
             NSInteger errorCode = 2000;
             NSString *domain = @"GoTogetherClient";
             
             jsonError = [NSError errorWithDomain:domain
                                             code:errorCode
                                         userInfo:[NSDictionary dictionaryWithObject:errorDescription
                                                                              forKey:@"errorDescription"]];
             handleFailure(jsonError);
             return;
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];
}

+ (void)updateFacebookAccessToken:(NSString *)accessToken
                           sucess:(void (^)(NSString *sucessMessage))handleSuccess
                          failure:(void (^)(NSError *error))handleFailure{

    User *currentUser = [User currentUser];
    if (currentUser == nil || accessToken == nil) {
        handleFailure(nil);
    }
    
    NSDictionary *parameters = nil;
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                  currentUser.userId, @"userid",
                  currentUser.accessToken, @"access_token",
                  accessToken,@"facebook_access_token",
                  nil];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_updateFacebookToken]
                       parameters:parameters];
    
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSError *jsonError = nil;
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             id error = [jsonDictionary valueForKey:@"error"];
             //id result = [jsonDictionary valueForKey:@"result"];
             
             if ([MMHTTPClient isError:error]) {
                 handleFailure(error);
                 return;
             }
             
             NSString *successMessage = @"Facebook session updated on server.";
             handleSuccess(successMessage);
         }else{
             
             NSString *errorDescription = @"Facebook Session update Failed. JSON is not a dictionary";
             NSInteger errorCode = 2000;
             NSString *domain = @"API";
             
             jsonError = [NSError errorWithDomain:domain
                                             code:errorCode
                                         userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:@"errorDescription"]];
             handleFailure(jsonError);
             return;
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];
}

+ (void)updateFacebookFriends:(NSString *)facebookFriends
                       sucess:(void (^)(NSString *sucessMessage))handleSuccess
                      failure:(void (^)(NSError *error))handleFailure{
    
    User *currentUser = [User currentUser];
    if (currentUser == nil || facebookFriends == nil) {
        handleFailure(nil);
    }
    
    NSDictionary *parameters = nil;
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                  currentUser.userId, @"userid",
                  currentUser.accessToken, @"access_token",
                  facebookFriends,@"facebook_friends",
                  nil];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_updateFacebookFriends]
                       parameters:parameters];
    
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSError *jsonError = nil;
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             id error = [jsonDictionary valueForKey:@"error"];
             //id result = [jsonDictionary valueForKey:@"result"];
             
             if ([MMHTTPClient isError:error]) {
                 handleFailure(error);
                 return;
             }
             
             [[NSNotificationCenter defaultCenter]
              postNotificationName:kNotificationType_facebookFriendsUpdatedOnGT
              object:nil];
             
             NSString *successMessage = @"Facebook Friends updated.";
             handleSuccess(successMessage);
         }else{
             
             NSString *errorDescription = @"Login Failed. JSON is not a dictionary";
             NSInteger errorCode = 2000;
             NSString *domain = @"API";
             
             jsonError = [NSError errorWithDomain:domain
                                             code:errorCode
                                         userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:@"errorDescription"]];
             handleFailure(jsonError);
             return;
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];
}

+ (void)loginUserWithUserId:(NSString *)userId
                   password:(NSString *)password
           sucess:(void (^)(NSString *successMessage))handleSuccess
          failure:(void (^)(NSError *error))handleFailure{
    
    NSDictionary *loginParameters = nil;
    loginParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                       userId, @"userid",
                       password, @"password",
                       nil];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_login]
                       parameters:loginParameters];
    
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSError *jsonError = nil;
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;             
             id error = [jsonDictionary valueForKey:@"error"];
             
             if ([MMHTTPClient isError:error]) {
                 NSDictionary *errorDict = (NSDictionary *)error;
                 NSString *errorDescription = [errorDict valueForKey:@"description"];
                 NSInteger errorCode = [[errorDict valueForKey:@"code"] integerValue];
                 NSString *domain = [errorDict valueForKey:@"domain"];
                 
                 jsonError = [NSError errorWithDomain:domain
                                                 code:errorCode
                                             userInfo:[NSDictionary dictionaryWithObject:errorDescription
                                                                                  forKey:@"errorDescription"]];
                 handleFailure(jsonError);
             }else {
                 
                 NSString *token = [[jsonDictionary valueForKey:@"result"] valueForKey:@"token"];
                 if (token !=nil) {
                     [User saveUserIdToUserDefaults:userId];
                     User *existingUser = [User userForUserId:userId];
                     if (existingUser == nil) {
                         [User saveNewUserWithUserId:userId andAccessToken:token];
                     }else{
                         [existingUser setAccessToken:token];
                     }
                     
                     [[NSNotificationCenter defaultCenter]
                      postNotificationName:kNotificationType_loginSuccessful
                      object:nil];

                     NSString *successMessage = @"Logged in Successfully!";
                     handleSuccess(successMessage);
                     
                 }else{
                     
                     NSString *errorDescription = @"Login Failed. Access Token not received!";
                     NSInteger errorCode = 2000;
                     NSString *domain = @"API";
                     
                     jsonError = [NSError errorWithDomain:domain
                                                     code:errorCode
                                                 userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:@"errorDescription"]];
                     handleFailure(jsonError);
                 }
                 
             }
         }else{
             
             NSString *errorDescription = @"Login Failed. JSON is not a dictionary";
             NSInteger errorCode = 2000;
             NSString *domain = @"API";
             
             jsonError = [NSError errorWithDomain:domain
                                             code:errorCode
                                         userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:@"errorDescription"]];
             handleFailure(jsonError);
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];
}

+ (void)resendVerificationCodeforUser:(User *)user
                               sucess:(void (^)(NSString *successMessage))handleSuccess
                              failure:(void (^)(NSError *error))handleFailure{
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSDictionary *registerParameters = nil;
    registerParameters = [NSDictionary dictionaryWithObjectsAndKeys:
                          user.userId, @"userid",
                          nil];
    
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_resendPin]
                       parameters:registerParameters];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSError *jsonError = nil;
         
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             id error = [jsonDictionary valueForKey:@"error"];
             //id result = [jsonDictionary valueForKey:@"result"];
             
             if ([MMHTTPClient isError:error]) {
                 handleFailure(error);
                 return;
             }
             
             NSString *successMessage = @"password resent!";
             handleSuccess(successMessage);
         }else{
             
             NSString *errorDescription = @"JSON is not a dictionary";
             NSInteger errorCode = 2000;
             NSString *domain = @"GoTogetherClient";
             
             jsonError = [NSError errorWithDomain:domain
                                             code:errorCode
                                         userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:@"errorDescription"]];
             handleFailure(jsonError);
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];
}

+ (void)getProfileDetailsForUserId:(NSString *)userId
                            sucess:(void (^)(User  *user))handleSuccess
                           failure:(void (^)(NSError *error))handleFailure{

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    User *currentUser = [User currentUser];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:currentUser.userId forKey:@"userid"];
    [parameters setObject:currentUser.accessToken forKey:@"access_token"];
    
    if ([currentUser.userId isEqualToString:userId] == NO) {
        [parameters setObject:userId forKey:@"friend_id"];
    }
    
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_myProfile]
                       parameters:parameters];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSError *jsonError = nil;
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             id error = [jsonDictionary valueForKey:@"error"];
             id result = [jsonDictionary valueForKey:@"result"];

             if ([MMHTTPClient isError:error]) {
                 handleFailure(error);
                 return;
             }
             
             if ([result isKindOfClass:[NSDictionary class]] && [[result allKeys] count]>0) {
                 
                 NSDictionary *dictionary = [result valueForKey:@"data"];

                 User *user = nil;
                 User *existingUser = [User userForUserId:userId];
                 if(existingUser == nil){
                     user = [User saveNewUserWithUserId:userId fromDictionary:dictionary];
                 }else{
                     user = [User updateUser:existingUser fromDictionary:dictionary];
                 }
                 
                 handleSuccess(user);
             }
         }else{
             
             NSString *errorDescription = @"JSON is not a dictionary";
             NSInteger errorCode = 2000;
             NSString *domain = @"GoTogetherClient";
             jsonError = [NSError errorWithDomain:domain
                                             code:errorCode
                                         userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:@"errorDescription"]];
             handleFailure(jsonError);
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];

}

+ (void)verifyPin:(NSString *)pin
           sucess:(void (^)(NSString *successMessage))handleSuccess
          failure:(void (^)(NSError *error))handleFailure{
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];    
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    User *currentUser = [User currentUser];
    NSDictionary *parameters = nil;
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                  currentUser.userId, @"userid",
                  currentUser.accessToken, @"access_token",
                  pin, @"pin",
                  nil];
    
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_verifyPhone]
                       parameters:parameters];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         
            NSDictionary *jsonDictionary = (NSDictionary *)JSON;
            id error = [jsonDictionary valueForKey:@"error"];
            NSDictionary *result = [jsonDictionary valueForKey:@"result"];
         
            if ([MMHTTPClient isError:error]) {
                NSError *errorObject = [MMHTTPClient errorObject:error];
                handleFailure(errorObject);
                return;
            }
            if ([result.allKeys containsObject:@"data"]) {
                NSDictionary *data = [result objectForKey:@"data"];
                NSString *token = [data objectForKey:@"token"];
                if (token !=nil) {
                 
                    NSString *userId = [User getUserId];
                    User *user = [User userForUserId:userId];
                    [user setAccessToken:token];
                 
                    [[NSManagedObjectContext MR_defaultContext]
                     MR_saveToPersistentStoreWithCompletion:nil];
                    NSString *successMessage = @"Pin verified!";
                    handleSuccess(successMessage);
                }else{
                    handleFailure(error);
                }
            }else{
                handleFailure(error);
            }

         }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
             handleFailure(error);
     }];
    [operation start];
}

+ (void)fetchUserLocationWithUserId:(NSString *)userIdString
                             sucess:(void (^)(CLLocationCoordinate2D coordinate))handleSuccess
                            failure:(void (^)(NSError *error))handleFailure{
    
    
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];

    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"GET"
                             path:[NSString stringWithFormat:@"%@?userid=%@",kRedHotApi_userLocation,userIdString]
                       parameters:nil];

/*TODO: This has to be converted to a POST Request
    User *currentUser = [User currentUser];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];

    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionary];
    [requestParameters setObject:currentUser.userId forKey:@"userid"];
    [requestParameters setObject:currentUser.accessToken forKey:@"access_token"];
    
    [requestParameters setObject:userIdString forKey:@""];
    
    NSMutableURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_userLocation]
                       parameters:requestParameters];
    */
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        NSDictionary *responseDictionary =[NSJSONSerialization
                                           JSONObjectWithData:responseObject
                                           options:NSJSONReadingMutableContainers
                                           error:nil];

        
        CLLocationCoordinate2D coordinate;
        NSDictionary *dataDictionary = [responseDictionary valueForKey:@"data"];
        coordinate.longitude = [[dataDictionary valueForKey:@"current_lon"] doubleValue];
        coordinate.latitude = [[dataDictionary valueForKey:@"current_lat"] doubleValue];
        handleSuccess(coordinate);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handleFailure(error);
    }];
    [requestOperation start];

}

+ (void)updateUser:(User *)user
            sucess:(void (^)(id response))handleSuccess
           failure:(void (^)(NSError *error))handleFailure
{    
    NSString *userId = [User getUserId];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (user.userId != nil) {
        [parameters setObject:userId forKey:@"userid"];
    }
    if (user.accessToken != nil) {
        [parameters setObject:user.accessToken forKey:@"access_token"];
    }
    if (user.facebookId != nil) {
        [parameters setObject:user.facebookId forKey:@"facebookid"];
    }
    if (user.name != nil) {
        [parameters setObject:user.name forKey:@"name"];
    }
    if (user.gender != nil) {
        [parameters setObject:user.gender forKey:@"gender"];
    }
    if (user.dateOfBirth != nil) {
        [parameters setObject:[NSDate dateOfBirthStringFromDate:user.dateOfBirth]
                       forKey:@"date_of_birth"];
    }
    if (user.phoneNumberVerified !=nil) {
        [parameters setObject:user.phoneNumberVerified forKey:@"phone_verified"];
    }
    if (user.profileDescription != nil) {
        [parameters setObject:user.profileDescription forKey:@"profile_description"];
    }
    if (user.workPlace != nil) {
        [parameters setObject:user.workPlace forKey:@"work_place"];
    }
    
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.deviceTokenString != nil) {
        [parameters setObject:appDelegate.deviceTokenString forKey:@"push_token"];
    }
    if (user.currentLongitude != nil) {
        [parameters setObject:user.currentLongitude forKey:@"current_lon"];
    }
    if (user.currentLatitude != nil) {
        [parameters setObject:user.currentLatitude forKey:@"current_lat"];
    }

    
    NSURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                     path:[NSString stringWithFormat:@"%@",kRedHotApi_updateUser]
                                               parameters:parameters];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSError *jsonError = nil;
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
            id error = [jsonDictionary valueForKey:@"error"];

             if ([MMHTTPClient isError:error]) {
                 handleFailure(error);
                 return;
             }
             
             NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
             [defaultContext MR_saveToPersistentStoreWithCompletion:nil];
                 
             NSString *successMessage = @"User updated!";
             handleSuccess(successMessage);
             return;
         }else{
             
             NSString *errorDescription = @"JSON is not a dictionary";
             NSInteger errorCode = 2000;
             NSString *domain = @"GoTogetherClient";
             
             jsonError = [NSError errorWithDomain:domain
                                             code:errorCode
                                         userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:@"errorDescription"]];
             handleFailure(jsonError);
             return;
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];
}

+ (void)addWorkPlaceWithLocation:(CLLocation *)workLocation
                    workLocality:(NSString *)workLocality
                    homeLocation:(CLLocation *)homeLocation
                    homeLocality:(NSString *)homeLocality
                          sucess:(void (^)(id response))handleSuccess
                         failure:(void (^)(NSError *error))handleFailure{
    
    NSString *userId = [User getUserId];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    User *user = [User currentUser];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (user.userId != nil) {
        [parameters setObject:userId forKey:@"userid"];
    }
    
    if (user.accessToken != nil) {
        [parameters setObject:user.accessToken forKey:@"access_token"];
    }
    
    if (workLocation != nil) {
        [parameters setObject:[NSNumber numberWithDouble:workLocation.coordinate.latitude]
                       forKey:@"work_lat"];
        [parameters setObject:[NSNumber numberWithDouble:workLocation.coordinate.longitude]
                       forKey:@"work_lon"];
        
    }
    
    if (homeLocation != nil) {
        [parameters setObject:[NSNumber numberWithDouble:homeLocation.coordinate.latitude]
                       forKey:@"home_lat"];
        [parameters setObject:[NSNumber numberWithDouble:homeLocation.coordinate.longitude]
                       forKey:@"home_lon"];
    }
    
    if (workLocality != nil) {
        [parameters setObject:workLocality forKey:@"work_locality"];
    }
    if (homeLocality !=nil) {
        [parameters setObject:homeLocality forKey:@"home_locality"];
    }

    NSURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                     path:[NSString stringWithFormat:@"%@",kRedHotApi_addWorkHome]
                                               parameters:parameters];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSError *jsonError = nil;
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             id error = [jsonDictionary valueForKey:@"error"];
             
             if ([MMHTTPClient isError:error]) {
                 handleFailure(error);
                 return;
             }
             
             NSString *successMessage = @"Work and Home added successfully";
             handleSuccess(successMessage);
             return;
         }else{
             
             NSString *errorDescription = @"JSON is not a dictionary";
             NSInteger errorCode = 2000;
             NSString *domain = @"GoTogetherClient";
             
             jsonError = [NSError errorWithDomain:domain
                                             code:errorCode
                                         userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:@"errorDescription"]];
             handleFailure(jsonError);
             return;
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];
}

+ (void)inviteContactWithPhoneNumber:(NSString *)phoneNumber
                              sucess:(void (^)(NSString *sucessMessage))handleSuccess
                             failure:(void (^)(NSError *error))handleFailure {

    User *user = [User currentUser];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (user.userId != nil) {
        [parameters setObject:user.userId forKey:@"userid"];
    }
    if (user.accessToken != nil) {
        [parameters setObject:user.accessToken forKey:@"access_token"];
    }
    if (phoneNumber !=nil) {
        [parameters setObject:phoneNumber forKey:@"mobile_number"];
    }
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                     path:[NSString stringWithFormat:@"%@",kRedHotApi_inviteFriends]
                                               parameters:parameters];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSError *jsonError = nil;
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             id error = [jsonDictionary valueForKey:@"error"];
             
             if ([MMHTTPClient isError:error]) {
                 NSError *errorObject = [MMHTTPClient errorObject:error];
                 handleFailure(errorObject);
                 return;
             }
             
             NSString *successMessage = @"Invitation Sent!";
             handleSuccess(successMessage);
             return;
         }else{
             
             NSString *errorDescription = @"JSON is not a dictionary";
             NSInteger errorCode = 2000;
             NSString *domain = @"GoTogetherClient";
             
             jsonError = [NSError errorWithDomain:domain
                                             code:errorCode
                                         userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:@"errorDescription"]];
             handleFailure(jsonError);
             return;
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];
}

#pragma mark - core data methods

+ (User *)userForUserId:(NSString *)userid {
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", userid];
    User *user = [User MR_findFirstWithPredicate:predicate inContext:defaultContext];
    if (user) {
        return user;
    }
    else{
        return nil;
    }
}

+ (void)saveUser:(User *)user andAccessToken:(NSString *)access_token {
    [user setAccessToken:access_token];
    [[user managedObjectContext] saveToPersistentStoreWithCompletion:nil];
}

+ (void)saveNewUserWithUserId:(NSString *)userId andAccessToken:(NSString *)access_token {

    User *userDetails = [User MR_createInContext:[NSManagedObjectContext defaultContext]];
    [userDetails setUserId:userId];
    [userDetails setEmail:userId];
    [userDetails setAccessToken:access_token];

    [[NSManagedObjectContext MR_defaultContext] saveToPersistentStoreWithCompletion:nil];
}

+ (User *)saveNewUserWithUserId:(NSString *)userId fromDictionary:(NSDictionary *)dictionary {
    
    User *newUser = [User MR_createInContext:[NSManagedObjectContext defaultContext]];
    
    NSString *accessToken = [dictionary valueForKey:@"accesstoken"];
    NSString *currentLatitude = [dictionary valueForKey:@"current_lat"];
    NSString *currentLongitude = [dictionary valueForKey:@"current_lon"];
    NSString *facebookId = [dictionary valueForKey:@"facebookid"];
    NSString *friends = [dictionary valueForKey:@"friends"];
    NSString *gender = [dictionary valueForKey:@"gender"];
    NSString *mobileNumber = [dictionary valueForKey:@"mobile"];
    NSString *phoneVerified = [dictionary valueForKey:@"phone_verified"];
    NSString *name = [dictionary valueForKey:@"name"];
    NSString *profileDescription = [dictionary valueForKey:@"profile_description"];
    NSString *userToken = [dictionary valueForKey:@"user_token"];
    NSString *facebookProfileUrl = [dictionary valueForKey:@"facebook_profile_url"];

    NSString *dateOfBirthString = [dictionary valueForKey:@"date_of_birth"];
    NSDate *dateOfBirth = [NSDate dateFromDateOfBirthString:dateOfBirthString];
    
    NSString *vehicle_model = [dictionary valueForKey:@"vehicle_model"];
    NSString *vehicle_number = [dictionary valueForKey:@"vehicle_number"];
    NSString *vehicle_make = [dictionary valueForKey:@"vehicle_make"];
    
    NSString *workPlace = [dictionary valueForKey:@"work_place"];
    newUser.userId = userId;
    if (accessToken !=nil && [accessToken length]>0) {
        newUser.accessToken = accessToken;
    }
    
    if (phoneVerified !=nil) {
        if ([[phoneVerified lowercaseString] isEqualToString:@"true"]) {
            newUser.phoneNumberVerifiedValue = TRUE;
        }else{
            newUser.phoneNumberVerifiedValue = FALSE;
        }
    }
    
    if (currentLatitude !=nil && [currentLatitude length]>0) {
        newUser.currentLatitudeValue = [currentLatitude doubleValue];
    }
    if (currentLongitude !=nil && [currentLongitude length]>0) {
        newUser.currentLongitudeValue = [currentLongitude doubleValue];
    }
    if (facebookId !=nil && [facebookId length]>0) {
        newUser.facebookId = facebookId;
    }
    if (friends !=nil && [friends length]>0) {
        newUser.friendsList = friends;
    }
    if (gender !=nil && [gender length]>0) {
        newUser.gender = gender;
    }
    if (mobileNumber !=nil && [mobileNumber length]>0) {
        newUser.mobile = mobileNumber;
    }
    if (name !=nil && [name length]>0) {
        newUser.name = name;
    }
    if (profileDescription !=nil && [profileDescription length]>0) {
        newUser.profileDescription = profileDescription;
    }
    if (dateOfBirth !=nil) {
        newUser.dateOfBirth = dateOfBirth;
    }
    if (userToken !=nil && [userToken length]>0) {
        newUser.pushToken = userToken;
    }

    if (workPlace !=nil && [workPlace length]> 0) {
        newUser.workPlace = workPlace;
    }
    
    if (facebookProfileUrl !=nil) {
        newUser.facebookProfileLink = facebookProfileUrl;
    }
    
    if (vehicle_make != nil && [vehicle_make length]> 0) {
        Vehicle *newVehicle = [Vehicle MR_createInContext:[NSManagedObjectContext defaultContext]];
        newVehicle.vehicleNumber = vehicle_number;
        newVehicle.make = vehicle_make;
        newVehicle.model = vehicle_model;
        newUser.vehicle = newVehicle;
    }
    
    [[NSManagedObjectContext defaultContext] MR_saveToPersistentStoreWithCompletion:nil];

    return newUser;
}

+ (User *)updateUser:(User *)user fromDictionary:(NSDictionary *)dictionary {
    
    NSString *accessToken = [dictionary valueForKey:@"accesstoken"];
    NSString *currentLatitude = [dictionary valueForKey:@"current_lat"];
    NSString *currentLongitude = [dictionary valueForKey:@"current_lon"];
    NSString *facebookId = [dictionary valueForKey:@"facebookid"];
    NSString *friends = [dictionary valueForKey:@"friends"];
    NSString *gender = [dictionary valueForKey:@"gender"];
    NSString *mobileNumber = [dictionary valueForKey:@"mobile"];
    NSString *phoneVerified = [dictionary valueForKey:@"phone_verified"];
    NSString *name = [dictionary valueForKey:@"name"];
    NSString *profileDescription = [dictionary valueForKey:@"profile_description"];
    NSString *facebookProfileUrl = [dictionary valueForKey:@"facebook_profile_url"];
    NSString *dateOfBirthString = [dictionary valueForKey:@"date_of_birth"];
    NSDate *dateOfBirth = [NSDate dateFromDateOfBirthString:dateOfBirthString];

    NSString *userToken = [dictionary valueForKey:@"user_token"];
    NSString *workPlace = [dictionary valueForKey:@"work_place"];
    
    NSString *vehicle_model = [dictionary valueForKey:@"vehicle_model"];
    NSString *vehicle_number = [dictionary valueForKey:@"vehicle_number"];
    NSString *vehicle_make = [dictionary valueForKey:@"vehicle_make"];

    if (accessToken !=nil && [accessToken length]>0) {
        user.accessToken = accessToken;
    }
    
    if (phoneVerified !=nil) {
        if ([[phoneVerified lowercaseString] isEqualToString:@"true"]) {
            user.phoneNumberVerifiedValue = TRUE;
        }else{
            user.phoneNumberVerifiedValue = FALSE;
        }
    }
    
    if (currentLatitude !=nil && [currentLatitude length]>0) {
        user.currentLatitudeValue = [currentLatitude doubleValue];
    }
    if (currentLongitude !=nil && [currentLongitude length]>0) {
        user.currentLongitudeValue = [currentLongitude doubleValue];
    }
    if (facebookId !=nil && [facebookId length]>0) {
        user.facebookId = facebookId;
    }
    if (friends !=nil && [friends length]>0) {
        user.friendsList = friends;
    }
    if (gender !=nil && [gender length]>0) {
        user.gender = gender;
    }
    if (mobileNumber !=nil && [mobileNumber length]>0) {
        user.mobile = mobileNumber;
    }
    if (name !=nil && [name length]>0) {
        user.name = name;
    }
    if (profileDescription !=nil && [profileDescription length]>0) {
        user.profileDescription = profileDescription;
    }
    if (dateOfBirth !=nil) {
        user.dateOfBirth = dateOfBirth;
    }
    if (userToken !=nil && [userToken length]>0) {
        user.pushToken = userToken;
    }
    if (workPlace !=nil && [workPlace length]> 0) {
        user.workPlace = workPlace;
    }
    
    if (facebookProfileUrl !=nil) {
        user.facebookProfileLink = facebookProfileUrl;
    }

    if (vehicle_make != nil && [vehicle_make length] > 0) {
        Vehicle *existingVehicle = [Vehicle vehicleForVehicleNumber:vehicle_number];
        if (existingVehicle == nil) {
            existingVehicle = [Vehicle MR_createInContext:[NSManagedObjectContext defaultContext]];
        }
        [existingVehicle setVehicleNumber:vehicle_number];
        [existingVehicle setMake:vehicle_make];
        [existingVehicle setModel:vehicle_model];
        
        user.vehicle = existingVehicle;
    }

    [[NSManagedObjectContext defaultContext]
     MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            TALog(@"success");
        }else{
            TALog(@"error: %@",error);
        }
    }];
    
    return user;
}

#pragma mark - convenience methods

+ (BOOL)doesUserExists {
    User *currentUser = [self currentUser];
    if (currentUser == nil) {
        return NO;
    }else {
        if ([currentUser userId] != nil && [currentUser accessToken] != nil) {
            return YES;
        }else{
            return NO;
        }
    }
}

- (BOOL)isUserLoggedIn {
    User *currentUser = [User currentUser];
    if (currentUser != nil && currentUser.accessToken!= nil) {
        return YES;
    }else{
        return NO;
    }
}

+ (User *)currentUser {
    NSString *userId = [User getUserId];
    User *currentUser = [User userForUserId:userId];
    return currentUser;
}

- (BOOL)isCurrentUser {
    User *currentUser = [User currentUser];
    return [self.userId isEqualToString:currentUser.userId];
}

+ (NSString *)userNameForEmailId:(NSString *)emailId {
    NSArray *array = [emailId componentsSeparatedByString:@"@"];
    if ([array count]> 0) {
       return [array objectAtIndex:0];
    }else {
        return nil;
    }
}

- (BOOL)isUserFacebookConnected {
    if (self.facebookId != nil){
        NSString *facebookID = [self.facebookId
                                stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if ([facebookID length]> 0) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - User Defaults

+ (void)setFacebookLoggedIn {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:@"facebookLogIn"];
    [userDefaults synchronize];
}

+ (BOOL)isFacebookLoggedIn {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:@"facebookLogIn"];
}

#pragma mark - User Defaults

+ (void)saveUserIdToUserDefaults:(NSString *)userId {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userId forKey:@"userId"];
    [userDefaults synchronize];
}

+ (NSString *)getUserId {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"userId"];
}

+ (void)resetUserDefaults {
    [NSUserDefaults resetStandardUserDefaults];
    [NSUserDefaults standardUserDefaults];
}

#pragma mark - work and home places

//- (BOOL)isWorkPlaceAvailable {
//    BOOL isAvailable = NO;
//    if (self.homePlace !=nil && [self.homePlace length] > 0) {
//        isAvailable = YES;
//    }
//    return isAvailable;
//}
//
//- (BOOL)isHomePlaceAvailable {
//    BOOL isAvailable = NO;
//    if (self.workPlace !=nil && [self.workPlace length] > 0) {
//        isAvailable = YES;
//    }
//    return isAvailable;
//}

@end
