#import "goTogetherAppDelegate.h"
#import "Reachability.h"
#import "TALocationManager.h"
#import "TAFacebookManager.h"
#import "GTBrowseViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "GTProfileViewController.h"
#import "CoreData+MagicalRecord.h"
#import "GTFriendsListViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MMRecord.h"
#import "MMLiveServer.h"
#import "GTAnalyticsManager.h"
#import "GTAroundMeViewController.h"
#import "SIAlertView.h"
#import "GTNotificationsManager.h"
#import "Mobihelp.h"
#import <Parse/Parse.h>
#import <ParseCrashReporting/ParseCrashReporting.h>

#define kAlertTag_pushNotification_requestRide 202

@interface goTogetherAppDelegate()
@end

@implementation goTogetherAppDelegate
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.rootViewController = (GTRootViewController *)self.window.rootViewController;
    
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"goTogetherData.sqlite"];
    [MMRecord registerServerClass:[MMLiveServer class]];

    // Register for remote notifications
    [self registerForPushNotificationsForApplication:application];
    
    // Handle remote notification
    NSDictionary *remoteNotification =
    [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification != nil) {
        [[GTNotificationsManager sharedInstance] handlePushNotificationWithDetails:remoteNotification];
    }

    [self loadAppearance];
    [self setupReachabilityHandlers];
    [GMSServices provideAPIKey:kGoogleMapsApiKey];
    [self setupParse:launchOptions];
    [self initialiseFreshDeskSupport];
    
    [self.window makeKeyAndVisible];
    
    if ([User isFacebookLoggedIn] == NO) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kNotificaionType_loggedOut
         object:nil];
        [self.rootViewController loadLoginViewControllerIfnotLoggedIn];
    }else{
        if ([User doesUserExists] == NO) {
            [self.rootViewController loadLoginViewControllerIfnotLoggedIn];
        }else{
            [self.rootViewController startServicesForLoggedInUser];
        }
    }

    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    return wasHandled;
}

- (void)registerForPushNotificationsForApplication:(UIApplication *)application {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else
#endif
    {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [self saveDeviceTokenToParse:deviceToken];
    
    
    self.deviceTokenString = [[NSMutableString alloc] init];
    _deviceTokenString = [[deviceToken description]
                          stringByTrimmingCharactersInSet:
                          [NSCharacterSet characterSetWithCharactersInString:@"<>"]
                          ];
    
    _deviceTokenString = [_deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    User *user =[User currentUser];
    if (user != nil && _deviceTokenString!= nil) {
        [User
         updateUserPushToken:_deviceTokenString
         sucess:^(NSString *sucessMessage) {
             TALog(@"Push token updated: %@",sucessMessage);
         } failure:^(NSError *error) {
             TALog(@"Push token updated failed. error : %@",error);
         }];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {

    if ([User doesUserExists]) {
        [[GTNotificationsManager sharedInstance]
         handlePushNotificationWithDetails:userInfo];

        [PFPush handlePush:userInfo];
        if (application.applicationState == UIApplicationStateInactive) {
            [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
        }
    }    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationDidBecomeActive:(UIApplication *)application	{
    // Clear All Notifications
    GTNotificationsManager *notificationsManager = [GTNotificationsManager sharedInstance];
    [notificationsManager clearAllNotifications];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kNotificaionType_appOpened
     object:self];
    
    [[TAFacebookManager sharedInstance] updateFacebookSession];
    
    self.rootViewController.didShowInviteAlert = NO;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSManagedObjectContext defaultContext]
     saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
         [MagicalRecord cleanUp];
    }];
    
    [FBSession.activeSession close];
    [self.networkReachability stopNotifier];
}


#pragma mark - Fresh Desk

- (void)initialiseFreshDeskSupport {
    MobihelpConfig *config = [[MobihelpConfig alloc]
                              initWithDomain:@"gotogether.freshdesk.com"
                              withAppKey:@"gotogether-2-fd1610962bd6579ffd8d2508254acf41"
                              andAppSecret:@"aef94c6c1b89e3f2afe75fb7057bf5e4aca38bf4"];
    
    [[Mobihelp sharedInstance] initWithConfig:config];
}

#pragma mark - Parse

- (void)setupParse:(NSDictionary *)launchOptions {
    
    [ParseCrashReporting enable];
    
    [Parse setApplicationId:kParseNotifications_appId
                  clientKey:kParseNotifications_clientKey];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [NSException raise:NSGenericException format:@"Everything is ok. This is just a test crash."];
//    });
    
    // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
    // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
    // [PFFacebookUtils initializeFacebook];
}

- (void)saveDeviceTokenToParse:(NSData *)deviceToken {
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"" ];
    [currentInstallation saveInBackground];
}

#pragma mark- UrbanAirship

- (void)setupUrbanAirship:(NSDictionary *)launchOptions {
//    UAConfig *config = [UAConfig defaultConfig];
//    [UAirship takeOff:config];
}

#pragma mark - Appearance

- (void)loadAppearance {

    if ([[UINavigationBar class]respondsToSelector:@selector(appearance)]) {
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            [[UINavigationBar appearance] setBarTintColor:kColorPalette_baseColor];
        }
        else {
            [[UINavigationBar appearance] setTintColor:kColorPalette_baseColor];
        }

        NSDictionary *textTitleOptions = [NSDictionary
                                          dictionaryWithObjectsAndKeys:
                                          [UIColor whiteColor], NSForegroundColorAttributeName, nil];

        [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];
    }
    if ([[UIBarButtonItem class]respondsToSelector:@selector(appearance)]) {
        [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    }
    
    if ([[UITabBar class]respondsToSelector:@selector(appearance)]) {
        [[UITabBar appearance] setTintColor:kColorPalette_baseColor];
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            [[UITabBar appearance] setBarTintColor:kColorGlobalBackground];
        }
        else {
            [[UITabBar appearance] setTintColor:kColorGlobalBackground];
        }
    }
    if ([[UISegmentedControl class] respondsToSelector:@selector(appearance)]) {
        [[UISegmentedControl appearance] setTintColor:kColor_blueShade];
    }
    if ([[UIStepper class] respondsToSelector:@selector(appearance)]) {
        [[UIStepper appearance] setTintColor:kColor_blueShade];
    }
}

#pragma mark - reachability
- (void) setupReachabilityHandlers{
    
    self.networkReachability = [Reachability reachabilityForInternetConnection];
    [self.networkReachability startNotifier];
    self.netStatus = [self.networkReachability currentReachabilityStatus];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector: @selector(reachabilityChanged:)
     name: kReachabilityChangedNotification
     object:nil];
}

- (void) reachabilityChanged: (NSNotification* )note{
    
    if ([[note object] isKindOfClass:[Reachability class]]) {
        self.networkReachability = [note object];
        self.netStatus = [self.networkReachability currentReachabilityStatus];
        switch (self.netStatus)
        {
            case ReachableViaWWAN:
            case ReachableViaWiFi:
            case NotReachable:
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:kReachabilityNotification
                 object:self];
                break;
        }
    }
}

@end
