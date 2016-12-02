//
//  Mobihelp.h
//  FreshdeskSDK
//
//  Copyright (c) 2014 Freshdesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  Used to specify what user information is collected when a conversation is started. Once the information is collected, the user is never bothered again.
 */
typedef NS_ENUM(NSInteger, FEEDBACK_TYPE) {
    /**
     *  Name and Email required.
     */
    FEEDBACK_TYPE_NAME_AND_EMAIL_REQUIRED = 1,
    /**
     *  Name Required and Email Optional.
     */
    FEEDBACK_TYPE_NAME_REQUIRED_AND_EMAIL_OPTIONAL,
    /**
     *  Anonymous.
     */
    FEEDBACK_TYPE_ANONYMOUS
};

/**
 *  This document describes the configuration options that are available for the Mobihelp iOS SDK.
 */
@interface MobihelpConfig : NSObject

/**
 * Used to enable/disable SSL. SSL is ON by default.
 */
@property (nonatomic) BOOL enableSSL;

/**
 *  Used to specify whether solutions should be prefetched. This can be set to NO if solution articles are not being used. Default value is YES.
 */
@property (nonatomic) BOOL prefetchSolutions;

/**
 *  Used to set the feedback type that specifies the amount of user information to be collected like name and email.
 */
@property (nonatomic) FEEDBACK_TYPE feedbackType;

@property (strong, nonatomic) NSString *appKey;
@property (strong, nonatomic) NSString *appSecret;
@property (strong, nonatomic) NSString *domain;

/**
 *  Initialize Mobihelp.
 *
 *  @discussion In order to initialize Mobihelp, you'll need the three parameters mentioned above. Place the Mobihelp initialization code in your app delegate, preferably at the top of the application:didFinishLaunchingWithOptions method. 
 *
 *  @param domain    The domain name for your portal.
 *
 *  @param appKey    The App Key assigned to your app when it was created on the portal.
 *
 *  @param appSecret The App Secret assigned to your app when it was created on the portal.
 *  
 */
-(instancetype)initWithDomain:(NSString*)domain withAppKey:(NSString*)appKey andAppSecret:(NSString*)appSecret;

/**
 *  Set the theme name.
 *
 *  @discussion Use this method to supply the SDK with your theme file's name. Make sure themeName is the same as the theme plist file's name. Mobihelp needs this for theming to work.
 *
 *  @param themeName Set Theme Name.
 *
 */
- (void)setThemeName:(NSString *) themeName;

@end

/**
 *  This document serves as an API reference for the Mobihelp iOS SDK.
 */
@interface Mobihelp : NSObject 

/**
 *  Access the Mobihelp instance.
 *
 *  @discussion Using the returned shared instance, you can access all the instance methods available in Mobihelp.
 */
+ (instancetype) sharedInstance;

/**
 *  Initialize configuration for Mobihelp.
 *
 *  @param config Mobihelp Configuration of type MobihelpConfig
 */
-(void)initWithConfig:(MobihelpConfig *)config;

/**
 *  Present the support view.
 *
 *  @discussion This method lets you present the support view in your app. The support view contains the list of conversations from the user and Solutions/FAQs.
 *
 *  @param parentViewController This is essentially the view controller from where you're attempting to present the support screen.
 *
 */
-(void)presentSupport:(UIViewController *) parentViewController;

/**
 *  Preset user's name and email address.
 *
 *  @discussion In case you already collect the user's details in your app, you can use that information to pass them on to Mobihelp. Mobihelp will not request this info again.
 *
 *  @param name  User's name.
 *
 *  @param email User's email address.
 *  @warning Throws an exception when username or email address is nil/invalid.
 *
 */
-(void)setUserName:(NSString *)name andEmailAddress:(NSString *)email;

/**
 *  Get the user's name.
 *
 *  @discussion Retrieve the user's name.
 */
-(NSString *)userName;

/**
 *  Get the user's email address.
 *
 *  @discussion Retrieve the user's email address.
 */
-(NSString *)emailAddress;

/**
 *  Present the feedback view.
 *
 *  @discussion This method lets you present the feedback view from your app. Users can submit their feedback from this screen.
 *
 *  @param parentViewController This is essentially the view controller from where you're attempting to present the feedback screen.
 *
 */
-(void)presentFeedback:(UIViewController *) parentViewController;

/**
 *  Show the list of conversations or tickets.
 *
 *  @discussion This method lets you show the inbox view that displays the user's conversations with your support agent.
 *
 *  @param parentViewController This is essentially the view controller where you're attempting to present the view containing the list of conversations/tickets for the user.
 *
 */
-(void)presentInbox:(UIViewController *)parentViewController;

/**
 *  Leave a new breadcrumb.
 *
 *  @discussion This method lets you leave a breadcrumb to track user activity in your App. A timestamp also gets attached to the breadcrumb automatically. 
 *
 *  @param crumbDetails A string that can be used to store useful debugging information.
 *   
 */
-(void)leaveBreadcrumb:(NSString *)crumbDetails;

/**
 *  Add new custom data in key-value format.
 *
 *  @discussion This method lets you collect useful data inside your app. This can be any Key Value information.
 *
 *  @param key   The custom data's key.
 *
 *  @param value The custom data's value.
 *
 */
-(void)addCustomDataForKey:(NSString *)key withValue:(NSString *)value;

/**
 *  App rating/review alert.
 *
 *  @discussion This method lets you throw an alert to the user, asking the user to rate/review your app on the App Store.
 */
-(void)launchAppReviewRequest;

/**
 *  Get the last updated unread conversations count.
 *
 *  @discussion This method returns the last updated count of conversations which require the user's attention. This may not always be up to date.
 */
-(NSInteger)unreadCount;

/**
 *  Get the unread conversations count.
 *
 *  @discussion This method lets you asynchronously fetch the latest count of conversations that require the user's attention. It is always up to date.
 *
 *  @param completion Completion block with count.
 *
 */
-(void)unreadCountWithCompletion:(void(^)(NSInteger count))completion;

/**
 *  Clear user data.
 *
 *  @discussion Can be used to clear user data when the user logs out of your app.
 */
-(void)clearUserData;

@end
