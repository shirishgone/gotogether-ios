//
//  GTAnalyticsConstants.h
//  GoTogether
//
//  Created by Shirish Gone on 5/29/13.
//  Copyright 2013
//



typedef enum{
    GTRideTypePublic = 0,
    GTRideTypeFriend
}GTRideType;

typedef enum{
    GTRequestTypeAsk = 0,
    GTRequestTypeOffer
}GTRequestType;

typedef enum{
    GTSocialShareVia_email = 0,
    GTSocialShareVia_whatsApp,
    GTSocialShareVia_twitter,
    GTSocialShareVia_facebook
}GTSocialShareVia;


typedef enum{
    GTRideRequestTypeBookSeat = 0,
    GTRideRequestTypeConfirmSeat
}GTRideRequestType;


#define FLURRY_PLIST_KEY_DICTIONARY                 @"FlurryAPIKeys"
#define FLURRY_DEVELOPMENT_KEY                      @"Development"
#define FLURRY_RELEASE_KEY                          @"Release"


#pragma mark - 
#define Analytics_created_RideType_and_RequestType     @"createRide_requestType"
#define Analytics_RideType_key                         @"rideType_key"
#define Analytics_RideType_value_public                @"rideType_value_public"
#define Analytics_RideType_value_friend                @"rideType_value_friend"

#define Analytics_RequestType_key                      @"requestType_key"
#define Analytics_RequestType_value_offer              @"requestType_value_offer"
#define Analytics_RequestType_value_ask                @"requestType_value_ask"


#define Analytics_RideLength_rideType                  @"rideLength_for_rideType"
#define Analytics_RideLength_key                       @"rideLength_key"

#define Analytics_SeatCount_rideType                   @"seatCount_for_rideType"
#define Analytics_SeatCount_key                        @"seatCount_key"

#define Analytics_CostPerKM_rideType                   @"costPerKM_for_rideType"
#define Analytics_CostPerKM_key                        @"costPerKM_key"

#define Analytics_Commented_rideType                   @"commented_for_rideType"
#define Analytics_Searched_rideType                    @"searched_for_rideType"

#define Analytics_vehicle_added                        @"vehicle_added"

#define Analytics_ride_shared_socially                 @"ride_shared_socially"

#define Analytics_socialSharing_via_key                @"socialshare_via_key"
#define Analytics_socialSharing_via_email              @"socialshared_via_email"
#define Analytics_socialSharing_via_whatsapp           @"socialshared_via_whatsapp"
#define Analytics_socialSharing_via_twitter            @"socialshared_via_twitter"
#define Analytics_socialSharing_via_facebook           @"socialshared_via_facebook"



#define Analytics_RideRequestType                      @"rideRequestType"
#define Analytics_RideRequestType_key                  @"rideRequestType_key"
#define Analytics_RideRequestType_value_bookSeat       @"rideRequestType_value_bookSeat"
#define Analytics_RideRequestType_value_confirmSeat    @"rideRequestType_value_confirmSeat"
