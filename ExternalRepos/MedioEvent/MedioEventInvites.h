//
//  MedioEventInvite.h
//  MedioEvent
//
//  Created by Toly Pochkin on 1/26/13.
//  Copyright 2011-2013 Medio. All rights reserved.
//


/**
 * Example of initial set up to verify that user has accepted an invitation or that his invitation
 * was accepted.
 */


#import <Foundation/Foundation.h>
#import "MedioEventCore.h"
#import "MEInviteServiceConfig.h"


#pragma mark - Reward

/// ------------------------------------------------------------------------------------------------------------------
/// Reward model
/// ------------------------------------------------------------------------------------------------------------------
@interface Reward : NSObject

/// List of channels.
@property (nonatomic, copy) NSArray* channels;
/// Reward name.
@property (nonatomic, copy) NSString* name;
/// Reward id.
@property (nonatomic, copy) NSString* rewardId;
/// Welcome text
@property (nonatomic, copy) NSString* welcomeText;
/// Welcome image URL.
@property (nonatomic, copy) NSString* welcomeImageURL;
/// Welcome title
@property (nonatomic, copy) NSString* welcomeTitle;
/// Action type
@property (nonatomic, copy) NSString* actionType;
/// Reporting type
@property (nonatomic, copy) NSString* reportingType;
/// Reward quantity
@property (nonatomic, copy) NSNumber* rewardQuantity;
/// Secret key
@property (nonatomic, copy) NSString* secretKey;
/// Callback URI
@property (nonatomic, copy) NSString* callbackUri;

/// Initialize reward instance from dictionary.
- (id)initWithDictionary:(NSDictionary*)dict;

@end


/// ------------------------------------------------------------------------------------------------------------------
/// Invite model
/// ------------------------------------------------------------------------------------------------------------------
@interface Invite : NSObject

/// Invite unique id
@property (nonatomic, copy) NSString* inviteId;
/// Invitation message
@property (nonatomic, copy) NSString* message;
/// Invitation subject (for EMAIL invites)
@property (nonatomic, copy) NSString* subject;
/// Invitation status (e.g. INSTALLED or CLAIMED)
@property (nonatomic, copy) NSString* status;
/// Invitation URL
@property (nonatomic, copy) NSString* url;
/// Time when invite was sent or updated
@property (nonatomic, copy) NSNumber* time;
/// Name of person invited
@property (nonatomic, copy) NSString* inviteeName;
/// Reward id
@property (nonatomic, copy) NSString* rewardId;
/// Channel name (e.g. TWITTER or EMAIL)
@property (nonatomic, copy) NSString* channel;
/// Claim available count
@property (nonatomic, copy) NSNumber* claimAvailableCount;
/// Install count
@property (nonatomic, copy) NSNumber* installCount;
/// Test install count
@property (nonatomic, copy) NSNumber* testInstallCount;
/// Pointer to Reward object for this invite
@property (nonatomic, strong) Reward* reward;

/// Initialize model with NSDictionary received as JSON response.
- (id)initWithDictionary:(NSDictionary*)dict;

/// Serializes model into NSDictionary
- (NSDictionary*)asDictionary;

@end



// Callbacks

/// checkForNewRewardWithBlock: callback
typedef void (^CheckForNewRewardsBlock)(Reward* reward, NSArray* invites);
/// acceptRewardForInvites: callback
typedef void (^AcceptRewardForInvitesBlock)(BOOL success);



#pragma mark - Invite service delegate


@protocol MEInviteServiceDelegate <NSObject>

@optional

/**
 * Gets called when invite dialog is about to be closed.
 */
- (void)willCloseInviteServiceDialog:(InviteService*)inviteService;

/**
 * Gets called when invite dialog is closed.
 */
- (void)didCloseInviteServiceDialog:(InviteService*)inviteService;

@end


#pragma mark - Invite service

/*******************************************************************************************************************
 Invite Service declaration.
 *******************************************************************************************************************/

@interface InviteService : NSObject

/** 
 * Delegate.
 */
@property (nonatomic, weak) id<MEInviteServiceDelegate> delegate;

/**
 * Set Invite Service config.
 */
@property (nonatomic, readonly) MEInviteServiceConfig* inviteServiceConfig;

/**
 * Resets the config.
 */
- (void)resetConfig;

/**
 * Show invite dialog. This is a core of Invite Service. New dialog will be displayed to the user.
 * User will be able to agree to send invite to his friends or to decline it. The entire publishing logic
 * is inside this method:
 * 1. Let the user to confirm that he wants to send invite to his friends.
 * 2. Show list of available invite channels (Facebook, Twitter, SMS etc).
 * 3. Let the user select networks to publish invites to.
 *
 * @param parent
 *              Parent view controller.
 */
- (void)showInviteDialogInParent:(UIViewController*)parent;

/**
 * Check for new rewards.
 */
- (void)checkForNewRewardWithBlock:(CheckForNewRewardsBlock)block;


/**
 * Accept rewards.
 */
- (void)acceptRewardForInvites:(NSArray*)invites withBlock:(AcceptRewardForInvitesBlock)block;


#pragma mark - Invite service lifecycle helpers


/**
 * Must be called from app delegate's applicationDidFinishLaunching: method. This is required for some invite
 * channels to operate correctly.
 *
 * Add this to your AppDelegate file:
 *
 * - (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
 *     [MEDIOEVENT handleApplicationDidFinishLaunching];
 * }
 */
- (BOOL)handleApplicationDidFinishLaunching;

/**
 * Must be called from app delegate's applicationDidBecomeActive: method. This is required for some invite
 * channels to operate correctly (e.g. Facebook will not work without this method getting called.)
 *
 * Add this to your AppDelegate file:
 *
 * - (void)applicationDidBecomeActive:(UIApplication *)application {
 *     [MEDIOEVENT handleApplicationDidBecomeActive];
 * }
 */
- (void)handleApplicationDidBecomeActive;

/**
 * Must be called from app delegate's applicationWillTerminate: delegate method. This is required for some
 * invite channels to operate correctly (e.g. Facebook will not work without this method getting called)
 * Note, since MedioEvent minimum requirements are iOS 4.2, this method gets called only when you application set 
 *    "Application does not run in background" = YES 
 * in app's plist file.
 *
 * Add this to you AppDelegate file:
 *
 * - (void)applicationWillTerminate:(UIApplication *)application {
 *     [MEDIOEVENT handleApplicationWillTerminate];
 * }
 */
- (void)handleApplicationWillTerminate;


/**
 * Must be called from app delegate's application:openURL:sourceApplication:annotation: method. This is required
 * for some invite channels to operate correctly (e.g. Facebook will not work without this method getting called).
 *
 * Add this to your AppDelegate file:
 *
 * - (BOOL)application:(UIApplication*)application openURL:(NSURL*)url
 *   sourceApplication:(NSString*)sourceApplication
            annotation:(id)annotation {
 *     return [MEDIOEVENT handleApplicationOpenURL:url];
 * }
 */
- (BOOL)handleApplicationOpenURL:(NSURL*)url;


@end
