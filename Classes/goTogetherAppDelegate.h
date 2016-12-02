#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "TAFacebookUser.h"
#import "Reachability.h"
#import "GTRootViewController.h"

@interface goTogetherAppDelegate : UIResponder <UIApplicationDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) Reachability *networkReachability;
@property (assign, nonatomic) NetworkStatus netStatus;
@property (strong, nonatomic) NSString *deviceTokenString;
@property (strong, nonatomic) GTRootViewController *rootViewController;

@end
