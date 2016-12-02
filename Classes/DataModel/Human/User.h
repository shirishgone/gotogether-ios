#import "_User.h"
#import <CoreLocation/CLLocation.h>
#import "Event.h"
#import "User.h"
#import "NSManagedObject+MagicalRecord.h"
#import "CoreData+MagicalRecord.h"
#import "TAFacebookUser.h"

@interface User : _User {}
// Custom logic goes here.

+ (BOOL)doesUserExists;
- (BOOL)isUserLoggedIn;
- (BOOL)isCurrentUser;
+ (User *)currentUser;
+ (NSString *)getUserId;
+ (void)resetUserDefaults;
+ (BOOL)isPhoneVerified;
+ (NSString *)userNameForEmailId:(NSString *)emailId;
- (BOOL)isUserFacebookConnected;

+ (void)setFacebookLoggedIn;
+ (BOOL)isFacebookLoggedIn;


// Registration and login
+ (void)loginWithFacebook:(User *)user
            facebookToken:(NSString *)facebookToken
                   sucess:(void (^)(void))handleSuccess
                  failure:(void (^)(NSError *error))handleFailure;

+ (void)registerUser:(User *)user
              sucess:(void (^)(NSString *successMessage))handleSuccess
             failure:(void (^)(NSError *error))handleFailure;

+ (void)sendPinToPhoneNumber:(NSString *)phoneNumber
                     Success:(void (^)(id success))handleSuccess
                     failure:(void (^)(NSError *error))handleFailure;


+ (void)loginUserWithUserId:(NSString *)userId
                   password:(NSString *)password
                     sucess:(void (^)(NSString *successMessage))handleSuccess
                    failure:(void (^)(NSError *error))handleFailure;

+ (void)logoutUserForSuccess:(void (^)(NSString *sucessMessage))handleSuccess
                     failure:(void (^)(NSError *error))handleFailure;

+ (void)forgotPasswordForEmailId:(NSString *)emailId
                         success:(void (^)(NSString *sucessMessage))handleSuccess
                         failure:(void (^)(NSError *error))handleFailure;

+ (void)verifyPin:(NSString *)pin
           sucess:(void (^)(NSString *successMessage))handleSuccess
          failure:(void (^)(NSError *error))handleFailure;

+ (void)resendVerificationCodeforUser:(User *)user
                               sucess:(void (^)(NSString *successMessage))handleSuccess
                              failure:(void (^)(NSError *error))handleFailure;

+ (void)fetchUserLocationWithUserId:(NSString *)userIdString
                             sucess:(void (^)(CLLocationCoordinate2D coordinate))handleSuccess
                            failure:(void (^)(NSError *error))handleFailure;


+ (User *)userForUserId:(NSString *)userid;

+ (void)getProfileDetailsForUserId:(NSString *)userId
                            sucess:(void (^)(User  *user))handleSuccess
                           failure:(void (^)(NSError *error))handleFailure;

// Update user details.
+ (void)updateUser:(User *)user
            sucess:(void (^)(id response))handleSuccess
           failure:(void (^)(NSError *error))handleFailure;

+ (void)updateUserPushToken:(NSString *)pushToken
                     sucess:(void (^)(NSString *sucessMessage))handleSuccess
                    failure:(void (^)(NSError *error))handleFailure;

+ (void)updateFacebookDetails:(TAFacebookUser *)facebookUserDetails
                       sucess:(void (^)(NSString *sucessMessage))handleSuccess
                      failure:(void (^)(NSError *error))handleFailure;

+ (void)updateFacebookFriends:(NSString *)facebookFriends
                       sucess:(void (^)(NSString *sucessMessage))handleSuccess
                      failure:(void (^)(NSError *error))handleFailure;

+ (void)updateUserLocation:(CLLocation *)location;

+ (void)updateFacebookAccessToken:(NSString *)accessToken
                           sucess:(void (^)(NSString *sucessMessage))handleSuccess
                          failure:(void (^)(NSError *error))handleFailure;

+ (void)inviteContactWithPhoneNumber:(NSString *)phoneNumber
                              sucess:(void (^)(NSString *sucessMessage))handleSuccess
                             failure:(void (^)(NSError *error))handleFailure;

+ (void)addWorkPlaceWithLocation:(CLLocation *)workLocation
                    workLocality:(NSString *)workLocality
                    homeLocation:(CLLocation *)homeLocation
                    homeLocality:(NSString *)homeLocality
                          sucess:(void (^)(id response))handleSuccess
                         failure:(void (^)(NSError *error))handleFailure;

@end
