//
//  MedioEvent.h
//  MedioEvent framework
//
//  Created by Toly Pochkin on 8/24/11.
//  Copyright 2011-2013 Medio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/NSNull.h>
#import "ContentManager.h"
#import "ContentItem.h"


#define MEDIOEVENT_SDK_IOS_3_SUPPORT


// SDK Name
#define MEDIO_EVENT_SDK_NAME @"MedioEvent"
// Platform
#define MEDIO_EVENT_SDK_PLATFORM @"iOS"
/** User-Agent - "<SDK_NAME> <SDK_VERSION> <PLATFORM>" */
#define MEDIO_EVENT_SDK_USER_AGENT      MEDIO_EVENT_SDK_NAME @" " MEDIO_EVENT_SDK_FULL_VERSION @" " MEDIO_EVENT_SDK_PLATFORM


/** Shortcut to simplify access. */
#define MEDIOEVENT       [MedioEvent instance]

/** Open UDID. */
#define DEVICEID_OPEN_UDID @"open_udid"
/** ODIN. */
#define DEVICEID_ODIN @"odin"
/** Device identifier for advertisers. */
#define DEVICEID_IDFA @"idfa"
/** Device identifier for vendors. */
#define DEVICEID_IDFV @"idfv"
/** MAC. */
#define DEVICEID_MAC  @"mac"

/** Tapjoy event schema field name. */
#define ADNETWORK_TAPJOY @"m.tapjoy"


#if !defined(OF_TYPE)
#define OF_TYPE(anyType)
#endif


/** Medio Event API exception. */
extern NSString* const MedioEventInvalidStateException;


#ifdef DEBUG
#define MEDIO_EVENT_ENABLE_DEBUG_MODE()     [MEDIOEVENT performSelector:@selector(enableDebugMode)]
#else
#warning MEDIO_EVENT_ENABLE_DEBUG_MODE() call is ignored in release mode.
#define MEDIO_EVENT_ENABLE_DEBUG_MODE()
#endif



// SDK constants
extern NSString* const kUserAttributeGenderKey;
extern NSString* const kUserAttributeGenderValue_Male;
extern NSString* const kUserAttributeGenderValue_Female;
extern NSString* const kUserAttributeDateOfBirthKey;


@class InviteService;


/**
 * Medio Event API.
 */
@interface MedioEvent : NSObject <CLLocationManagerDelegate, UIWebViewDelegate>
{
@protected
    // Storage to keep extra information that may be required by schema code generator
    NSMutableDictionary* _extraStorage;
}


/**
 * Optionally add an application defined user Id to all events logged. This is useful if the application
 * wants to associate all logged events with a specific user. Note the EventAPI SDK automatically associates all
 * events with an anonymous Id. Applications can use this method if they want to identify events with a
 * non-anonymous Id or application defined Id.
 */
@property (strong) NSString* userId;

/**
 * Optionally add an application defined partner Id to all events logged. This is useful if the application
 * wants to associate all logged events with a specific partner Id. An example of a partner Id is if an application
 * has version 1.0, but branded for sponsor A, B and C. Then A, B and C can each be used as a partner Id so the
 * event logs can be differentiated between different partners or sponsors in this example.
 */
@property (strong) NSString* partnerId;

/**
 * Anonymous user id.
 */
@property (copy, readonly) NSString* anonymousId;

/**
 * Game level.
 */
@property (strong) NSString* gameLevel;

/**
 * Flight id.
 */
@property (strong) NSString* flightId;

/**
 * Optionally keep the session open when the app goes to background. 
 * SDK will close the session (if opened) when the app goes to background by default.
 * {@code YES} if the SDK should continue the session when app goes to background.
 */
@property (assign) BOOL continueSessionInBackground;

/** YES if device identifiers are enabled. */
@property (assign) BOOL deviceIdentifiersEnabled;

/** Custom advertising network identifiers. */
@property (strong) NSMutableDictionary * customNetworkIds;

/** Content manager. */
@property (strong, readonly) ContentManager* contentManager;


#pragma mark - Initialization

/**
 * Returns shared instance of EventAPI.
 */
+ (MedioEvent*)instance;

/**
 * Configure API secret key of the Event Web Service where this library will send logged events.
 * This method should only be called once in the application life cycle.
 *
 * @param apiKey
 *            API secret key.
 *
 * @return  YES, if operation was successful; NO, otherwise (if apiKey is nil or if Medio Event API was already configured).
 */
- (BOOL)configureWithAPIKey:(NSString*)apiKey;

/**
 * Configure the URL and API secret key of the Event Web Service where this library will send
 * logged events. These values must be set for events to be sent to the web service. We recommend calling this in
 * application:didFinishLaunchingWithOptions: selector in your main application delegate. EventAPI also requires
 * proper shutdown which we recommend to perform in applicationWillTerminate: selector.
 * This method should only be called once in the application life cycle.
 
 * @param serviceURL
 *            URL of Event Web Service. Cannot be nil or empty.
 * @param apiKey
 *            API secret key.
 *
 * @return  YES, if operation was successful; NO, otherwise (if serviceURL or apiKey is nil or if Medio Event API was
 *          already configured).
 *
 * NOTE This selector is deprecated and will be removed in next version.
 */
- (BOOL)configureWithURL:(NSString*)serviceURL
             usingAPIKey:(NSString*)apiKey
            __attribute__((deprecated));

/**
 * Open session.
 * We recommend calling this in application:didFinishLaunchingWithOptions: selector in your main application
 * delegate. EventAPI also requires closing a session which we recommend to perform in applicationWillTerminate:
 * selector.
 *
 * @return  YES, if session was successfully open. NO, if session was previously opened.
 *
 */
- (BOOL)openSession;

/**
 * Close the current event logging session. We recommend calling this in applicationWillTerminate: selector.
 *
 * @return  YES, if session was successfully closed. NO, if session was previously closed.
 *
 */
- (BOOL)closeSession;

/**
 * Call this method to send events to the cloud. This can only be called after configureWithURL: selector has been
 * called. Assumes data connection is available. It is recommended that the application checks if there is data
 * connectivity available before calling this method. If no data connection, this method will do nothing.
 * The library will ignore new calls to flushEvents, if previous flushEvents is currently being performed.
 * @return  YES, if operation was successful; NO, otherwise.
 */
- (BOOL)flushEvents;


#pragma mark - Logger


/**
 * Add log entry.
 * @param   type        Event type.
 * @return  YES, if log record was successfully processed; NO, otherwise (e.g. if type is invalid or if
 *          Medio Event SDK was not configured).
 */
- (BOOL)logEvent:(NSString*)type;

/**
 * Add log entry with extra parameter.
 * @param   type            Event type.
 * @param   parameter       Parameter.
 * @return  YES, if log record was successfully processed; NO, otherwise.
 */
- (BOOL)logEvent:(NSString*)type withParameter:(id)parameter;

/**
 * Add log entry with parameters map.
 * @param   type            Event type.
 * @param   parameters      Parameters map.
 * @return  YES, if log record was successfully processed; NO, otherwise.
 */
- (BOOL)logEvent:(NSString*)type withParametersMap:(NSDictionary*)parameters;

/**
 * Add log entry with parameters map.
 * @param   type            Event type.
 * @param   firstObject     The first value to add to the new dictionary.
 *                          First the key for firstObject, then a null-terminated list of alternating
 *                          values and keys.
 * @return  YES, if log record was successfully processed; NO, otherwise.
 *
 * @throws  NSInvalidArgumentException  Number of keys doesn't match number of values
 *
 * Example:
 * [MEDIOEVENT logEvent:@"MY_EVENT" withObjectsAndKeys:@"value1", @"key1", @"value2", @"key2", nil];
 */
- (BOOL)logEvent:(NSString*)type withObjectsAndKeys:(id)firstObject, ...;

/**
 * Add log entry with array of parameters.
 * @param   type            Event type.
 * @param   parameters      List of parameters.
 * @return  YES, if log record was successfully processed; NO, otherwise.
 */
- (BOOL)logEvent:(NSString*)type withParametersArray:(NSArray*)parameters performEncoding:(BOOL)performEncoding;

/**
 * Add log entity with feature and/or category as well as with some optional parameters.
 * @return  YES, if log record was successfully processed; NO, otherwise.
 */
- (BOOL)        logEvent:(NSString*)type feature:(NSString*)feature category:(NSString*)category
       withParametersMap:(NSDictionary*)parameters;

/**
 * Add log entity with feature and/or category as well as with some optional parameters.
 * @return  YES, if log record was successfully processed; NO, otherwise.
 */
- (BOOL)        logEvent:(NSString*)type feature:(NSString*)feature category:(NSString*)category
      withObjectsAndKeys:(id)firstObject, ...;

/**
 * Optionally add a key-value pair to all events logged. This is a convenience method for automatically adding a
 * key-value pair to each event logged instead of explicitly adding the same key-value pair to each method call
 * to logEvent. It is the app's responsibility to set these common key value pairs every time the app starts
 * fresh and to set/remove these common key value pairs any time their values change or no longer apply.
 * Common key-value pairs are not retroactive i.e. setting a common key value pair only affects new events logged
 * and does not affect events that have already been queued up or sent to server.
 * 
 * @param key
 *            The key to automatically add to each event logged. Although the API does not enforce a limit on string
 *            lengths, you should maintain a reasonable limit so the system remains deterministic. nil key
 *            is not allowed.
 * @param value
 *            The value to associate with key and automatically added to each event logged. Although the
 *            API does not enforce a limit on string lengths, you should maintain a reasonable limit so the system
 *            remains deterministic. null values will be converted to "null" string. This value will replace
 *            any key-value pair set prior with that has the same key.
 * @return  YES, if log record was successfully processed; NO, otherwise.
 */
- (BOOL)setValue:(NSString*)value forCommonKey:(NSString*)key;

/**
 * Remove a common key-value pair added with setValue:forCommonKey: selector.
 * @param key
 *            The key of the key-value pair to remove.
 * @return  YES, if operation was successful; NO, otherwise.
 */
- (BOOL)removeValueWithCommonKey:(NSString*)key;

/**
 * Print quick summary.
 */
- (void)printSummary;

/**
 * Print all log items.
 */
- (void)printFullLog;

/**
 * Set user attribute.
 */
- (void)setUserAttributeValue:(NSString*)value forKey:(NSString*)key;

/**
 * Set list of user attribute values for a specific key.
 */
- (void)setUserAttributeValues:(NSArray*)value forKey:(NSString*)key;

/**
 * Set user attribute with date value.
 */
- (void)setUserAttributeYear:(int)year month:(int)month day:(int)day forKey:(NSString*)key;

/**
 * Delete user attribute.
 */
- (void)removeUserAttributeForKey:(NSString*)key;




#pragma mark - Promotion Manager

/**
 * Call this method to log an "impression" event when a {@link ContentItem} is rendered/displayed for the user.
 * Logging impressions of content and counting the number of times content is shown to a user is an important
 * metric. This impression count can be used to validate ad spend/earned and it can be compared against clicks to
 * calculate effectiveness of ads/offers.
 *
 * @param contentItem
 *            The {@link ContentItem} displayed to the user. The item is obtained from the {@link ContentAPI}.
 * @return {@code true} if impression count for item was logged successfully. {@code false} otherwise, e.g.
 *         {@code null} or invalid item. A {@code true} return code means the event is stored in our queue for a
 *         batch send to our servers. It does not mean the event was sent successfully to our servers.
 */
- (BOOL)logImpressionEvent:(ContentItem*)contentItem;

/**
 * Call this method to log "click" event when a {@link ContentItem} when user clicks on a content item. Logging and
 * counting content clicks is an important metric to calculate effectiveness of ads/offers.
 *
 * @param contentItem
 *            The {@link ContentItem} clicked by user. The item is obtained from the {@link ContentAPI}.
 * @return {@code true} if event was logged successfully. {@code false} otherwise, e.g. {@code null} or invalid
 *         item.
 */
- (BOOL)logClickEvent:(ContentItem*)contentItem;

/**
 * Call this method to log "click" event when a {@link ContentItem} when user clicks on a content item. Logging and
 * counting content clicks is an important metric to calculate effectiveness of ads/offers.
 *
 * @param contentItem
 *            The {@link ContentItem} clicked by user. The item is obtained from the {@link ContentAPI}.
 * @return {@code true} if event was logged successfully. {@code false} otherwise, e.g. {@code null} or invalid
 *         item.
 */
- (BOOL)logAcceptEvent:(ContentItem*)contentItem;

/**
 * Call this method to log "click" event when a {@link ContentItem} when user clicks on a content item. Logging and
 * counting content clicks is an important metric to calculate effectiveness of ads/offers.
 *
 * @param contentItem
 *            The {@link ContentItem} clicked by user. The item is obtained from the {@link ContentAPI}.
 * @return {@code true} if event was logged successfully. {@code false} otherwise, e.g. {@code null} or invalid
 *         item.
 */
- (BOOL)logDeclineEvent:(ContentItem*)contentItem;


#pragma mark - Device IDs

/**
 * Set custom advertising network identifier.
 * @param   type                Ad network type.
 * @param   identifier          ID generated by ad network.
 */
- (void)setAdvertisingIdWithType:(NSString*)type andId:(NSString*)identifier;

/**
 * Enable logging device identifiers. This should be called before configure.
 * @param   identifier  identifier to log.
 */
- (BOOL)enableDeviceIdentifiers:(NSString *) identifier, ...;

#pragma Invites

/**
 * @return
 *              Reference to Invite Service singleton.
 */
- (InviteService*)inviteService;


#pragma mark - Debugging

/**
 * Enable MedioEvents debug output. By default this option is disabled.
 * This is helpful to troubleshoot and track MedioEvents activities.
 * @param   flag        YES, to enable debug output; NO, to disable.
 */
- (void)enableDebugOutput:(BOOL)flag;

/**
 * Set YES, if MedioEvent framework runs from unit test.
 * Otherwise Core Data will not function properly. Must be set before setupForOgranization:channel:
 * selector is being called.
 */
@property (nonatomic, assign) BOOL runForUnitTestOnly;

/**
 * Optionally disable automatic flushing of events to Medio DCS.
 * Events can still be flushed with {@link #flushEvents}.
 * Automatic flushing can be re-enabled any time by calling {@link #enableAutomaticFlushing}. 
 */
- (void)disableAutomaticFlushing;

/**
 * Automatic flushing of events to Medio DCS is enabled by default.
 * Call this optional method to re-enable automatic flushing if you have disabled automatic flushing
 * using {@link #disableAutomaticFlushing} method.
 * Note {@link #flushEvents} may still be called when automatic flushing is enabled.
 */
- (void)enableAutomaticFlushing;

/**
 * Optionally enable or disable automatic logging of location information with each event.
 * By default location logging is not enabled. Add CoreLocation.framework to your project
 * to be able to get location information from the device 
 * @param enable
 *          YES if you want to log location otherwise NO.
 */
- (void)logLocationWithEvents:(BOOL)enable;

/**
 * Identify the ID of the test device so the ID can be uploaded to K-Invite developer dashboard.
 */
- (void)printTestDeviceID;

@end


#if __cplusplus
extern "C"
{
#endif
    /** Set the platform to report. For internal use only. */
    int MedioEvent_setPlatform(const char* platform);
    /** Configure Medio Event SDK. */
    int MedioEvent_configureWithApiKey(const char* apiKey);
    /** Configure Medio Event SDK. */
    int MedioEvent_configure(const char* serviceURL, const char* username,
                             const char* password, const char* applicationId);
    /** Configure Medio Event SDK. */
    int MedioEvent_configureWithAll(const char* apiKey, const char* serviceURL, const char* kInviteURL);
    /** Set the autoflush period. */
    int MedioEvent_setAutoFlushPeriod(int period);
    /** Get Anonymous ID. */
    const char* MedioEvent_getAnonymousId(void);
    /** Open session. */
    int MedioEvent_openSession(void);
    /** Close session. */
    int MedioEvent_closeSession(void);
    /** Flush events. */
    int MedioEvent_flushEvents(void);
    /** Log event type only. */
    int MedioEvent_logEventType(const char* type);
    /** Log event and single key/value. */
    int MedioEvent_logEventTypeAndKeyValue(const char* type, const char* key, const char* value);
    /** Log event and multiple keys/values. */
    int MedioEvent_logEventTypeAndKeysValues(const char* type, int count, const char** keysValues);
    /** Log event with feature and category. */
    int MedioEvent_logEventFeatureAndCategory(const char* type, const char* feature, const char* category, int count, const char ** keysValues);
    /** Add common keys/values. */
    int MedioEvent_addCommonKeysValues(int count, const char** keysValues);
    /** Remove common key/value. */
    int MedioEvent_removeCommonKey(const char* key);
    /** Enable automatic flushing. */
    void MedioEvent_enableAutomaticFlushing(void);
    /** Disable automatic flushing. */
    void MedioEvent_disableAutomaticFlushing(void);
    /** Log location with events. */
    void MedioEvent_logLocationWithEvents(int enable);
    /** Set user id. */
    void MedioEvent_setUserId(const char* userId);
    /** Set partner id. */
    void MedioEvent_setPartnerId(const char* partnerId);
    /** Set anonymous id. */
    void MedioEvent_setAnonymousId(const char* anonymousId);
    /** Set to continue session in a background. */
    void MedioEvent_setContinueSessionInBackground(int enable);
    /** Print full log. */
    void MedioEvent_printFullLog(void);
    /** Enable Debug Mode. */
    void MedioEvent_enableDebugMode(void);
    /** Set custom advertising network identifier. */
    void MedioEvent_setAdvertisingId(const char* type, const char* advId);
    /** Enable logging device identifiers. This should be called before configure. The array must be NULL terminated. */
    int MedioEvent_enableDeviceIdentifiers(const char* identifiers[]);
    /** Get the flight id. */
    const char* MedioEvent_getFlightId(void);
    /** Set the flight id. */
    void MedioEvent_setFlightId(const char* flightId);
    /** Gets the game level to be logged. */
    const char* MedioEvent_getGameLevel(void);
    /** Sets the game level to be logged. */
    void MedioEvent_setGameLevel(const char* level);
    /** Set custom network ids. */
    void MedioEvent_setNetworkIds(int count, const char** keysValues);
    /** Get custom network ids. */
    const char** MedioEvent_getNetworkIds(void);
    
    /** Show invite dialog. */
    void MedioEvent_showInviteDialog(void);
    /** Check and accept rewards */
    int MedioEvent_checkAndAcceptReward(void);
    /** Print test device IDs. */
    void MedioEvent_printTestDeviceID(void);
    /** Reset Invite Service Config. */
    void MedioEvent_resetInviteConfig(void);
    /** Invite Service Config: set value. */
    void MedioEvent_setInviteServiceConfigValue(const char* name, const char* value);
    /** Set list of user attribute values for a specific key. */
    void MedioEvent_setUserAttributeValues(int count, const char** values, const char* key);
    /** Set user attribute with date value. */
    void MedioEvent_setUserAttributeDate(int year, int month, int day, const char* key);
    /** Delete user attribute. */
    void MedioEvent_removeUserAttributeForKey(const char* key);

    /** Set Campaign. */
    void MedioEvent_setCampaign(const char* campaign);
    /** Get Campaign. */
    const char* MedioEvent_getCampaign(void);
    /** Set Acquisition Channel. */
    void MedioEvent_setAcquisitionChannel(const char* acquisitionChannel);
    /** Get Acquisition Channel. */
    const char* MedioEvent_getAcquisitionChannel(void);
    /** Set Purchase Cart Id. */
    void MedioEvent_setPurchaseCartId(const char* purchaseCartId);
    /** Get Purchase Cart Id. */
    const char* MedioEvent_getPurchaseCartId(void);
    /** Open Purchase Cart */
    void MedioEvent_openPurchaseCart(void);
    /** Close Purchase Cart */
    void MedioEvent_closePurchaseCart(void);
    /** Log Earn Event */
    int MedioEvent_logEarnEvent(double earnAmount, const char* currency, const char* earnOptionsJSON, int count, const char** keyValues);
    /** Log Purchase Event */
    int MedioEvent_logPurchaseEvent(const char* itemId, double unitPrice, const char* currency, int isCurrencyVirtual, int quantity, const char* purchaseOptionsJSON, int count, const char** keyValues);
    
    /** Called when application becomes active. */
    void MedioEvent_applicationDidBecomeActive(void);
    /** Called when application launches with options. */
    void MedioEvent_applicationDidFinishLaunching(void);
    /** Called when application quits. */
    void MedioEvent_applicationWillTerminate(void);

    /** Set ContentAPI URL. */
    int MedioEvent_setCcpUrl(const char* ccpUrl);
    /** ContentAPI log impression. */
    int MedioEvent_logImpressionEvent(const char* contentItemJson);
    /** ContentAPI log click. */
    int MedioEvent_logClickEvent(const char* contentItemJson);
    /** ContentAPI log accept. */
    int MedioEvent_logAcceptEvent(const char* contentItemJson);
    /** ContentAPI log decline. */
    int MedioEvent_logDeclineEvent(const char* contentItemJson);

    /** Get content items */
    const char* MedioEvent_requestContentItemsWithContentOptions(const char* contentOptionsJson, const char* contextStr, int maxItems);

#if __cplusplus
}
#endif

