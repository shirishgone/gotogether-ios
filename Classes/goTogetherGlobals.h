//
//  Globals.h
//  goTogether
//
//  Created by Shirish on 11/18/11.
//  Copyright (c) 2011 gotogether. All rights reserved.
//


#ifndef goTogetherGlobals_h
#define goTogetherGlobals_h

#pragma mark - MACROS

#import "MMSynthesizeSingletonByChoice.h"

#pragma mark - CONSTANTS

#pragma mark - OTHER
#define MR_ENABLE_ACTIVE_RECORD_LOGGING 1

#define MR_SHORTHAND
#import "CoreData+MagicalRecord.h"

#define kReachabilityNotification @"ReachabilityNotification"

typedef void(^MMVoidBlock)(void);
typedef void(^MMBOOLBlock)(BOOL yesNo);

#endif

//----  To disable all Logs in release mode ----//
#ifdef DEBUG
#define TALog( s, ... ) NSLog(s, ## __VA_ARGS__)
#else
#define TALog( s, ... )
#endif

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define kAppStore_appId     @""
#define kFacebook_appId     @""
#define kGoogleMapsApiKey   @""
#define kInMobiAdProperty   @""
#define kInvite_API_KEY     @""

#define kSupportPhoneNumber @"+917032656010"
#define kPrivacyPolicyUrl @"http://www.gotogether.mobi/privacy.html"
#define kTermsOfServiceUrl @"http://www.gotogether.mobi/terms.html"

#define kParseNotifications_appId @""
#define kParseNotifications_clientKey @""

#define kGoogleAnalyticsTrackingId @""

#define kResizeHeight   170.0
#define kAlertDisplayTime 2
#define kDatePickerHeight 260.0f
#define kKeyboardHeight 216.0f
#define kToolbarHeight 44.0f
#define kMetersToKiloMeters 1000
#define kAnimationDuration_fadeIn   0.65
#define kTableScrollAnimationDuration 0.35
#define kRouteLineThickness  3.5f
#define kNearByRadius 30

#define kSeatsAllowed_min 1
#define kSeatsAllowed_max 9

#define kCostPerKM_Slab1_LessThan5KM 10
#define kCostPerKM_Slab2_LessThan10KM 8.0
#define kCostPerKM_Slab3_LessThan20KM 6.0
#define kCostPerKM_Slab4_LessThan50KM 5.0
#define kCostPerKM_Slab5_LessThan100KM 4.5
#define kCostPerKM_Slab6_Above100KM 4.0

#define kEventType_friends @"friends"
#define kEventType_everybody @"everybody"

#define kUserType_owner @"owner"
#define kUserType_passenger @"passenger"


#define kPrivacyPolicyAcceptedKey               @"privacyPolicyAcceptedKey"
#define kNotificationsObjectKey                 @"Notifications"

#define kStoryBoardIdentifier_rideDetails       @"RideDetailStoryboard"
#define kStoryBoardIdentifier                   @"MainStoryboard"
#define kLoginStoryBoardIdentifier              @"LoginStoryboard"
#define kCellIdentifier_friendFeed              @"cellIdentifier_friendFeed"
#define kCellIdentifier_searchResult            @"cellIdentifier_searchResult"


#define kCellIdentifier_invite                  @"cellIdentifier_invite"
#define kCellIdentifier_friendList              @"cellIdentifier_friendList"
#define kCellIdentifier_iconKeyValue            @"cellIdentifier_iconKeyValue"
#define kCellIdentifier_imdrivingOrNeedARide    @"cellIdentifier_imdrivingOrNeedARide"
#define kCellIdentifier_seatCountAndCost        @"cellIdentifier_seatCountAndCost"
#define kCellIdentifier_rideVisibility          @"cellIdentifier_rideVisibility"
#define kCellIdentifier_facebookShare           @"cellIdentifier_facebookShare"

#define kCellIdentifier_daySelection            @"cellIdentifier_daySelection"
#define kCellIdentifier_notification_friendRequest  @"cellIdentifier_notification_friendRequest"
#define kCellIdentifier_notification_createdEvent   @"cellIdentifier_notification_createdEvent"
#define kCellIdentifier_notification_pickup         @"cellIdentifier_notification_pickup"


#define kcellType_createdEventNotifications     @"cellType_createdEventNotifications"
#define kcellType_acceptedPickUpNotifications   @"cellType_acceptedPickUpNotifications"

#define kCellIdentifierEventDetails_comment             @"cellIdentifierEventDetails_comment"
#define kCellIdentifierEventDetails_description         @"cellIdentifierEventDetails_description"
#define kCellIdentifierEventDetails_vehicleDetails      @"cellIdentifierEventDetails_vehicleDetails"
#define kCellIdentifierEventDetails_coTravellersList    @"cellIdentifierEventDetails_coTravellersList"
#define kCellIdentifierEventDetails_bookSeatNotification    @"cellIdentifierEventDetails_bookSeatNotification"
#define kCellIdentifierEventDetails_requestRideButton    @"cellIdentifierEventDetails_requestRideButton"


#define kCellIdentifier_profile_bio             @"cellIdentifier_profile_bio"
#define kCellIdentifier_profile_vehicle         @"cellIdentifier_profile_vehicle"
#define kCellIdentifier_profile_verifications   @"cellIdentifier_profile_verifications"
#define kCellIdentifier_profile_mutualfriends   @"cellIdentifier_profile_mutualfriends"


#define kCellIdentifier_profile_name            @"cellIdentifier_profile_name"
#define kCellIdentifier_profile_work            @"cellIdentifier_profile_work"
#define kCellIdentifier_profile_phoneNumber     @"cellIdentifier_profile_phonenumber"
#define kCellIdentifier_profile_vehicleNumber   @"cellIdentifier_profile_vehiclenumber"
#define kCellIdentifier_profile_add_vehicle     @"cellIdentifier_profile_add_vehicle"
#define kCellIdentifier_profile_addDescription  @"cellIdentifier_profile_addDescription"
#define kCellIdentifier_profile_logout          @"cellIdentifier_profile_logout"
#define kCellIdentifier_profile_friends         @"cellIdentifier_profile_friends"


#define kCellIdentifier_location_home         @"cellIdentifier_location_home"
#define kCellIdentifier_location_work         @"cellIdentifier_location_work"
#define kCellIdentifier_commutetime_towork    @"cellIdentifier_commutetime_towork"
#define kCellIdentifier_commutetime_tohome    @"cellIdentifier_commutetime_tohome"
#define kCellIdentifier_vehicle_available     @"cellIdentifier_vehicle_available"
#define kCellIdentifier_vehicle_make          @"cellIdentifier_vehicle_make"
#define kCellIdentifier_vehicle_model         @"cellIdentifier_vehicle_model"


#define kCellIdentifier_add_home_work   @"cellIdentifier_add_home_work"
#define kCellIdentifier_home_work       @"cellIdentifier_home_work"
#define kCellIdentifier_myride          @"cellIdentifier_myride"
#define kCellIdentifier_comments        @"cellIdentifierComments_comment"


//#define kCellIdentifier_notifications_comment       @"cellIdentifier_notifications_comment"
//#define kCellIdentifier_notifications_createEvent   @"cellIdentifier_notifications_createEvent"
//#define kCellIdentifier_notifications_editEvent     @"cellIdentifier_notifications_editEvent"
//#define kCellIdentifier_notifications_bookSeat      @"cellIdentifier_notifications_bookSeat"
//#define kCellIdentifier_notifications_acceptSeat    @"cellIdentifier_notifications_acceptSeat"

#define kCellIdentifier_notification   @"cellIdentifier_notification"

#define kViewControllerIdentifier_launchScreen          @"viewControllerIdentifier_launchScreen"
#define kViewControllerIdentifier_login                 @"viewControllerIdentifier_login"
#define kViewControllerIdentifier_registration          @"viewControllerIdentifier_registration"
#define kViewControllerIdentifier_phoneNumberVerify     @"viewControllerIdentifier_phoneNumberVerify"
#define kViewControllerIdentifier_privacyPolicy         @"viewControllerIdentifier_privacyPolicy"
#define kViewControllerIdentifier_liveFeed              @"viewControllerIdentifier_liveFeed"
#define kViewControllerIdentifier_home                  @"viewControllerIdentifier_home"
#define kViewControllerIdentifier_createRide            @"viewControllerIdentifier_createRide"
#define kViewControllerIdentifier_searchRide            @"viewControllerIdentifier_searchRide"
#define kViewControllerIdentifier_about                 @"viewControllerIdentifier_about"
#define kViewControllerIdentifier_add                   @"viewControllerIdentifier_add"
#define kViewControllerIdentifier_addVehicle            @"viewControllerIdentifier_addVehicle"
#define kViewControllerIdentifier_addAdvanced           @"viewControllerIdentifier_addAdvanced"
#define kViewControllerIdentifier_homeWorkPlace         @"viewControllerIdentifier_homeWorkPlace"
#define kViewControllerIdentifier_aroundMe_search_nav   @"viewControllerIdentifier_aroundMe_search_nav"
#define kViewControllerIdentifier_aroundMe_search       @"viewControllerIdentifier_aroundMe_search"
#define kViewControllerIdentifier_aroundMe              @"viewControllerIdentifier_aroundMe"
#define kViewControllerIdentifier_searchMap             @"viewControllerIdentifier_searchMap"
#define kViewControllerIdentifier_mapAnnotation         @"viewControllerIdentifier_mapAnnotation"
#define kViewControllerIdentifier_settingsPopover       @"viewControllerIdentifier_settingsPopover"
#define kViewControllerIdentifier_searchResults         @"viewControllerIdentifier_searchResults"
#define kViewControllerIdentifier_profile               @"viewControllerIdentifier_profile"
#define kViewControllerIdentifier_profileEdit           @"viewControllerIdentifier_profileEdit"
#define kViewControllerIdentifier_friendsList           @"viewControllerIdentifier_friendsList"
#define kViewControllerIdentifier_notifications         @"viewControllerIdentifier_notifications"

#define kViewControllerIdentifier_routeMap              @"viewControllerIdentifier_routeMap"
#define kViewControllerIdentifier_buildProfile          @"viewControllerIdentifier_buildProfile"
#define kViewControllerIdentifier_inviteFriends         @"viewControllerIdentifier_inviteFriends"
#define kViewControllerIdentifier_addBio           @"viewControllerIdentifier_addBio"



#define kViewControllerIdentifier_rideDetailsParent     @"controller_ridedetails_parent"
#define kViewControllerIdentifier_rideDetails           @"controller_ridedetails"
#define kViewControllerIdentifier_rideDetailsTravellersList  @"controller_ridedetails_travellers"
#define kViewControllerIdentifier_messages              @"controller_ridedetails_messages"



#define kNavControllerIdentifier_add                    @"navcontroller_identifier_add"
#define kNavControllerIdentifier_homeWorkPlace          @"navControllerIdentifier_homeWorkPlace"

#define kViewControllerIdentifier_myRides @"viewControllerIdentifier_myRides"
#define kViewControllerIdentifier_parentProfile @"viewControllerIdentifier_parentProfile"

#define kSegueIdentifier_launchScreenToLogin            @"segueIdentifier_launchToLogin"
#define kSegueIdentifier_launchScreenToRegister         @"segueIdentifier_launchToRegister"
#define kSegueIdentifier_liveFeedToSearch               @"segueIdentifier_liveFeedToSearch"
#define kSegueIdentifier_liveFeedToFriends              @"segueIdentifier_liveFeedToFriends"

#define kSegueIdentifier_liveFeedToCreateEvent          @"segueIdentifier_liveFeedToCreateEvent"
#define kSegueIdentifier_addToLocationSelector          @"segueIdentifier_addToLocationSelector"
#define kSegueIdentifier_addRideToAddVehicle            @"segueIdentifier_addRideToAddVehicle"

#define kSegueIdentifier_searchRideTosearchLocation     @"segueIdentifier_searchRideToSearchLocation"


#define kSegueIdentifier_searchToRideDetails            @"segueIdentifier_searchToRideDetails"
#define kSegueIdentifier_searchToSearchEntry            @"segueIdentifier_searchToSearchEntry"
#define kSegueIdentifier_searchToSearchList             @"segueIdentifier_searchToSearchList"

#define kSegueIdentifier_aroundMeContainerToAddRide     @"segueIdentifier_aroundMeContainerToAddRide"
#define kSegueIdentifier_aroundMeContainerToRideDetails @"segueIdentifier_aroundMeContainerToRideDetails"
#define kSegueIdentifier_aroundMeToAdd                  @"segueIdentifier_aroundMeToAdd"

#define kSegueIdentifier_registrationToSearchLocation     @"segueIdentifier_registrationToSearchLocation"


#define kSegueIdentifier_activityToCreateEvent          @"segueIdentifier_activityToCreateEvent"
#define kSegueIdentifier_searchRideToSearchResults      @"segueIdentifier_searchRideToSearchResults"
#define kSegueIdentifier_searchResultsToRideDetails     @"segueIdentifier_searchResultsToRideDetails"
#define kSegueIdentifier_searchResultsToAdd             @"segueIdentifier_searchResultsToAdd"


#define kSegueIdentifier_createEventToRouteMap          @"segueIdentifier_createEventToRouteMap"
#define kSegueIdentifier_createEventToSearchLocation    @"segueIdentifier_createEventToSearchLocation"
#define kSegueIdentifier_eventDetailsToCreateEvent      @"segueIdentifier_eventDetailsToCreateEvent"
#define kSegueIdentifier_eventDetailsToComments         @"segueIdentifier_eventDetailsToComments"

#define kSegueIdentifier_myRidesToEventDetails          @"segueIdentifier_myRidesToEventDetails"
#define kSegueIdentifier_profileToAddDescription        @"segueIdentifier_profileToAddDescription"
#define kSegueIdentifier_profileToEditProfile           @"segueIdentifier_profileToEditProfile"
#define kSegueIdentifier_profileToAbout                 @"segueIdentifier_profileToAbout"


#define kSegueIdentifier_profileToAddWorkHomePlace      @"segueIdentifier_profileToAddWorkHomePlace"
#define kSegueIdentifier_profileToAddVehicle            @"segueIdentifier_profileToAddVehicle"


#define kSegueIdentifier_friendsListToInviteFriends     @"segueIdentifier_friendsListToInviteFriends"
#define kSegueIdentifier_friendsListToProfile           @"segueIdentifier_friendsListToProfile"

#pragma mark - Colors

#define kColor_orange [UIColor colorWithRed:185/255.0 green:88/255.0 blue:81/255.0 alpha:1.0]
#define kColor_blue [UIColor colorWithRed:41/255.0 green:170/255.0 blue:226/255.0 alpha:1.0]
#define kColor_gray [UIColor colorWithRed:110/255.0 green:99/255.0 blue:99/255.0 alpha:1.0]

#define kColor_darkgreen [UIColor colorWithRed:23/255.0 green:114/255.0 blue:89/255.0 alpha:1.0]
#define kColor_blueShade [UIColor colorWithRed:37/255.0 green:162/255.0 blue:189/255.0 alpha:1.0]

#pragma - Color Palette
#define kColorPalette_baseColor [UIColor colorWithRed:32/255.0 green:177/255.0 blue:138/255.0 alpha:1.0]
#define kColorPalette_whiteColor [UIColor whiteColor]
#define kColorPalette_grayColor [UIColor colorWithRed:190/255.0 green:195/255.0 blue:199/255.0 alpha:1.0]
#define kColorPalette_darkGreen [UIColor colorWithRed:56/255.0 green:72/255.0 blue:92/255.0 alpha:1.0]
#define kColorPalette_redColor [UIColor colorWithRed:253/255.0 green:98/255.0 blue:102/255.0 alpha:1.0]


#define kColorGlobalBackground      [UIColor colorWithRed:(242.0/255.0) green:(244.0/255.0) blue:(247.0/255.0)alpha:1.0]
#define kRouteColor_blue [UIColor colorWithRed:(42.0/255.0) green:(143.0/255.0) blue:(228.0/255.0) alpha:1.0]
#define kRouteColor_green [UIColor colorWithRed:(82.0/255.0) green:(174.0/255.0) blue:(85.0/255.0) alpha:1.0]
#define kRouteColor_red [UIColor colorWithRed:(223.0/255.0) green:(83.0/255.0) blue:(68.0/255.0) alpha:1.0]


#pragma mark - Fonts

#define kFont_alba_Regular_45 [UIFont fontWithName:@"Alba" size:45]
#define kFont_alba_Regular_25 [UIFont fontWithName:@"Alba" size:25]

#define kFont_GothamCond_Medium_20 [UIFont fontWithName:@"GothamCondensed-Medium" size:23]
#define kFont_GothamCond_Medium_18 [UIFont fontWithName:@"GothamCondensed-Medium" size:18]
#define kFont_GothamCond_Medium_16 [UIFont fontWithName:@"GothamCondensed-Medium" size:16]
#define kFont_GothamCond_Medium_14 [UIFont fontWithName:@"GothamCondensed-Medium" size:14]

#define kFont_HelveticaNeueBold_20 [UIFont fontWithName:@"HelveticaNeue-Bold" size:20]
#define kFont_HelveticaNeueBold_13 [UIFont fontWithName:@"HelveticaNeue-Bold" size:13]
#define kFont_HelveticaNeueBold_14 [UIFont fontWithName:@"HelveticaNeue-Bold" size:14]
#define kFont_HelveticaNeueRegular_14 [UIFont fontWithName:@"HelveticaNeue-Regular" size:14]
#define kFont_HelveticaNeueRegular_12 [UIFont fontWithName:@"HelveticaNeue-Regular" size:12]
#define kFont_HelveticaNeueRegular_10 [UIFont fontWithName:@"HelveticaNeue-Regular" size:10]


#pragma mark - API calls

#define kRedHotApi_liveBaseUrl_production    @""
#define kRedHotApi_liveBaseUrl_development    @""
//#define kRedHotApi_liveBaseUrl_development   @""
#define kRedHotApi_localBaselUrl  @"http://10.0.1.67:8001/"

#define kRedHotApi_loginWithFacebook  @"facebook_login"
#define kRedHotApi_register       @"register"
#define kRedHotApi_login          @"login"

#define kRedHotApi_browseRides    @"browse_rides"
#define kRedHotApi_friendFeed     @"friends_activity"
#define kRedHotApi_aroundMe       @"around_me"

#define kRedHotApi_resendPin      @"resend_verification"
#define kRedHotApi_verifyPhone    @"verify_user"
#define kRedHotApi_createEvent    @"create_event"
#define kRedHotApi_updateUser     @"edit_profile"
#define kRedHotApi_addVehicle     @"add_vehicle"
#define kRedHotApi_addWorkHome    @"add_work_home_place"
#define kRedHotApi_logoutUser     @"logout"
#define kRedHotApi_forgotPassword @"forgot_password"
#define kRedHotApi_sendPin        @"send_pin"



#define kRedHotApi_eventSearch    @"event_search"



#define kRedHotApi_myEvents       @"my_activity"
#define kRedHotAPi_editEvent      @"edit_event"
#define kRedHotAPi_cancelEvent    @"delete_event"
#define kRedHotApi_userLocation   @"user_location"
#define kRedHotApi_bookSeat       @"book_seat"
#define kRedHotApi_confirmSeat    @"confirm_seat"
#define kRedHotApi_eventDetails   @"event_details"
#define kRedHotApi_getComments    @"get_comments"
#define kRedHotApi_addComment     @"add_comment"
#define kRedHotApi_myProfile      @"my_profile_detail"
#define kRedHotApi_inviteFriends  @"send_invitation"
#define kRedHotApi_acceptFriendRequest  @"AcceptFriendRequest"
#define kRedHotApi_routepoints    @"route_points"
#define kRedHotApi_friends_list    @"get_friends"
#define kRedHotApi_updateFacebookFriends @"update_friends"
#define kRedHotApi_updateFacebookToken @"update_facebook_token"
#define kRedHotApi_getVehicles    @"get_vehicles"
#define kRedHotApi_mutualFriends  @"mutual_friends"

#pragma mark - Notifications

#define kNotificaionType_appOpened              @"notificationType_appOpened"
#define kNotificationType_eventDeleted          @"notificationType_eventDeleted"
#define kNotificationType_locationUpdated       @"notificationType_locationUpdated"
#define kNotificationType_locationTurnedOFF     @"notificationType_locationTurnedOff"
#define kNotificationType_addTouched            @"notificationType_addTouched"

#define kNotificationType_requestedPickup       @"notificationType_requestedPickup"
#define kNotificationType_acceptedPickup        @"notificationType_acceptedPickup"
#define kNotificationType_requestedSeat         @"notificationType_requestedSeat"
#define kNotificationType_acceptedSeat          @"notificationType_acceptedAccepted"
#define kNotificationType_commentedOnEvent      @"notificationType_commentedOnEvent"

#define kNotificationType_friendRequest         @"notificationType_friendRequest"
#define kNotificationType_friendRequestAccepted @"notificationType_friendRequestAccepted"
#define kNotificationType_eventCreated          @"notificationType_eventCreated"
#define kNotificationType_loginSuccessful       @"notificationType_loginSuccessful"

#define kNotificaionType_newEventCreated        @"notificationType_newEventCreated"
#define kNotificaionType_eventUpdated           @"notificationType_eventUpdated"
#define kNotificaionObject_updatedEvent         @"notificaionObject_updatedEvent"

#define kNotificaionType_comment                @"kNotificaionType_comment"
#define kNotificaionType_loggedOut              @"kNotificaionType_loggedOut"

#define kFacebookConnected_sendObject               @"facebookConnected_sendObject"
#define kFacebookFailed_sendObject                  @"facebookFailed_sendObject"
#define kNotificationType_facebookConnected         @"notificationType_facebookConnected"
#define kNotificationType_facebookConnectFailed     @"notificationType_facebookFailed"
#define kNotificationType_facebook_sessionUpdated   @"notificationType_facebook_sessionUpdated"
#define kNotificationType_facebookDetailsUpdatedOnGT    @"notificationType_facebookDetailsUpdatedOnGT"
#define kNotificationType_facebookFriendsUpdatedOnGT    @"notificationType_facebookFriendsUpdatedOnGT"

#define kNotificationType_phoneVerified            @"notificationType_phoneVerified"

#pragma mark - Messaging

#define kConnectToFacebookMessage @"Connect to facebook to see your friends rides & share yours."
#define kLocationServicesDisabledMessage @"If you would like to see rides near you, please give location access to gotogether in Settings app."

#define kLocationAccessMessage @"Inorder to show rides near you, we need access to your location. Please grant access, for this feature to work."


#define kInviteMessage_login @"Having a min of 5 friends who travel your routes, increases the chances of catching up."
#define kInviteMessage_noresults @"Dint find any rides ??? Invite your friends, who often travel your route. Next time, you have more chances of catching up."
#define kInviteMessage_ride_posted @"Let your friends know about your rides, so that they can catch up with you."


typedef enum {
    viewController_search,
    viewController_myRides,
    viewController_friendFeed,
    viewController_profile
}GTViewController;

typedef enum {
    shareWith_friends,
    shareWith_everybody
}GTShareWith;

typedef enum {
    switchType_facebook,
    switchType_visibility
}GTSwitchType;

typedef enum {
    GTRideDetailsVisibility_friendEvent,
    GTRideDetailsVisibility_searchEvent
}GTRideDetailsVisibility;

typedef enum {
    recurring_On,
    recurring_Off
}GTRecurring;

typedef enum {
    userType_passenger,
    userType_driving
}GTUserType;

typedef enum {
    eventType_public,
    eventType_private
}GTEventType;

typedef enum {
    eventMode_createEvent = 0,
    eventMode_editEvent = 1,
    eventMode_repostEvent = 2
}GTEventMode;

typedef enum {
    GTEventCellType_friendFeed = 0,
    GTEventCellType_searchResult = 1,
    GTEventCellType_myEvent = 2
}GTEventCellType;


typedef enum {
    rowIndex_top,
    rowIndex_middle,
    rowIndex_bottom,
    rowIndex_independent
}GTRowIndex;

typedef enum {
    EmptySearch,
    SourceSearch,
    DestinationSearch,
}GTSearchLocationType;

typedef enum {
    serverType_localServer,
    serverType_liveServer
}GTServerType;

typedef enum {
    myRidesType_bookings,
    myRidesType_offers
}GTMyRidesType;

typedef enum {
    GTMapPointerType_Start,
    GTMapPointerType_end
}GTMapPointerType;

