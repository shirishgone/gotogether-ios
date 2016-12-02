//
//  TAGoogleAPIManager.m
//  TravelApp
//
//  Created by shirish on 24/11/12.
//  Copyright (c) 2012 mutualmobile. All rights reserved.
//

#import "TAGoogleAPIManager.h"
#import "AFHTTPRequestOperation.h"
#import "Place.h"
#import "AFJSONRequestOperation.h"
#import "TALocationManager.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "goTogetherAppDelegate.h"
#import "Place.h"
#import "GTPlacesManager.h"

static const NSString *kGooglePlaceDetailsBaseUrl = @"https://maps.googleapis.com/maps/api/place/details/json";
static const NSString *kGooglePlacesBaseUrl = @"https://maps.googleapis.com/maps/api/place/textsearch/json";
static NSString *kGoogleLocationNameApi     = @"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=false";
int const kGooglePlaceSearch_Radius = 5000;

static TAGoogleAPIManager *sharedInstance = nil;

@interface  TAGoogleAPIManager()
@end

@implementation TAGoogleAPIManager

+(TAGoogleAPIManager*)sharedInstance
{
    @synchronized([TAGoogleAPIManager class])
    {
        if (!sharedInstance){
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
    return nil;
}

+ (TARoute *)routeForRoutePoints:(NSArray *)routePoints
            withSourceCoordinate:(CLLocationCoordinate2D)sourceCoordinate
           destinationCoordinate:(CLLocationCoordinate2D)destinationCoordinate{

    TARoute *route = [[TARoute alloc] init];
    [route setRoutePoints:routePoints];
    
    CLLocationDistance distance = [TALocationManager
     distanceBetweenCoordinate:sourceCoordinate
     andSecondCoordinate:destinationCoordinate];
    
    route.distance = distance;
    return route;
}

- (void)placesForString:(NSString *)queryString
               ifSucess:(void(^)(NSArray *places))handlePlaces
              ifFailure:(void(^)(NSError *error))handleError {
    
    CLLocation *currentLocation = [[TALocationManager sharedInstance] currentLocation];
    double currentLatitude = currentLocation.coordinate.latitude;
    double currentLongitude = currentLocation.coordinate.longitude;
    
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?input=%@&key=%@&sensor=true&components=country:in&location=%f,%f&radius=%d",queryString,kGoogleMapsApiKey,currentLatitude,currentLongitude,kGooglePlaceSearch_Radius];
    
    NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    TALog(@"url string : %@",encodedUrlString);
    
    NSURL *url = [NSURL URLWithString:encodedUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *error = nil;
        id completeResponse = [NSJSONSerialization JSONObjectWithData:responseObject
                                                              options:NSJSONReadingAllowFragments error:&error];
        TALog(@"compelte Response: %@",completeResponse);
        
        NSArray *results = [completeResponse valueForKey:@"results"];
        
        NSMutableArray *returnArray = [[NSMutableArray alloc] init];
        for (NSDictionary *result in results) {
            if ([result isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *geometry = [result valueForKey:@"geometry"];
                NSDictionary *location = [geometry valueForKey:@"location"];
                double latitude = [[location valueForKey:@"lat"] doubleValue];
                double longitude = [[location valueForKey:@"lng"] doubleValue];
                
                
                Place *place = [[GTPlacesManager sharedInstance] temporaryPlace];
                [place setPlaceName:[result valueForKey:@"name"]];
                [place setFormattedPlaceName:[result valueForKey:@"formatted_address"]];
                [place setReference:[result valueForKey:@"reference"]];
                [place setLatitude:[NSNumber numberWithDouble:latitude]];
                [place setLongitude:[NSNumber numberWithDouble:longitude]];
                
                [returnArray addObject:place];
            }
        }
        
        handlePlaces(returnArray);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        TALog(@"error: %@",error);
        
    }];
    [requestOperation start];

}

- (void)resetCurrentPlaces{
    [[GTPlacesManager sharedInstance] cleanupTemporaryContext];
}

- (void)placeDetailsForReference:(NSString *)referenceString
               ifSucess:(void(^)(id place))handlePlaceDetails
              ifFailure:(void(^)(NSError *error))handleError {
    
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@?reference=%@&sensor=true&key=%@",
                           kGooglePlaceDetailsBaseUrl,
                           referenceString,
                           kGoogleMapsApiKey];
    
    
    NSString *encodedUrlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    TALog(@"url string : %@",encodedUrlString);
    
    NSURL *url = [NSURL URLWithString:encodedUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *error = nil;
        id completeResponse = [NSJSONSerialization JSONObjectWithData:responseObject
                                                              options:NSJSONReadingAllowFragments error:&error];
        TALog(@"compelte Response: %@",completeResponse);
        
        NSDictionary *resultDict = [completeResponse valueForKey:@"result"];
        Place *placeObj = [self placeFromDict:resultDict save:YES];
        handlePlaceDetails(placeObj);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        TALog(@"error: %@",error);
        
    }];
    [requestOperation start];
    
}

- (Place *)placeFromDict:(NSDictionary *)dict save:(BOOL)save{
    
    NSString *subLocalityName = nil;
    NSString *localityName = nil;
    NSString *formattedAddress = nil;
    NSString *placeName = nil;
    NSNumber *latitude = nil;
    NSNumber *longitude = nil;
    NSString *reference = nil;

    NSArray *addressComponents = [dict valueForKey:@"address_components"];
    for (id component in addressComponents) {
        NSArray *componentTypes = [component valueForKey:@"types"];
        for (NSString *componentType in componentTypes) {
            if ([componentType isEqualToString:@"sublocality"]) {
                subLocalityName = [component valueForKey:@"short_name"];
            }else if ([componentType isEqualToString:@"locality"]){
                localityName = [component valueForKey:@"short_name"];
            }
        }
    }

    reference = [dict valueForKey:@"reference"];
    formattedAddress = [dict valueForKey:@"formatted_address"];
    placeName = [dict valueForKey:@"name"];
    
    NSDictionary *geometry = [dict valueForKey:@"geometry"];
    NSDictionary *location = [geometry valueForKey:@"location"];
    latitude = [location valueForKey:@"lat"];
    longitude = [location valueForKey:@"lng"];

    Place *placeObj = nil;
    if (save == YES) {
        placeObj =
        [Place savePlaceWithPlaceName:placeName
                            reference:reference
                             latitude:latitude
                            longitude:longitude
                      subLocalityName:subLocalityName
                         localityName:localityName
                     formattedAddress:formattedAddress
         ];
    }else{
        placeObj = [[GTPlacesManager sharedInstance] temporaryPlace];
        placeObj.placeName = placeName;
        placeObj.reference = reference;
        placeObj.latitude = latitude;
        placeObj.longitude = longitude;
        placeObj.subLocalityName = subLocalityName;
        placeObj.localityName = localityName;
        placeObj.formattedPlaceName = formattedAddress;
    }
    
    return placeObj;
}

- (void)fetchLocationNameForLatitude:(CLLocationDegrees)latitude
                           longitude:(CLLocationDegrees)longitude
                            ifSucess:(void(^)(Place *place))handlePlace
                           ifFailure:(void(^)(NSError *error))handleError {

    NSString *urlString = [NSString
                           stringWithFormat:kGoogleLocationNameApi,
                           latitude,
                           longitude
                           ];
    
    TALog(@"urlString : %@",urlString);
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:urlRequest
     success:^(NSURLRequest *request,
               NSHTTPURLResponse *response,
               id JSON) {
         NSDictionary *resultDict = (NSDictionary *)JSON;
         TALog(@"JSON: %@", JSON);
         
         NSArray *resultsArray = [resultDict valueForKey:@"results"];
         if ([resultsArray count] > 0) {
             
             NSDictionary *singleAddress = [resultsArray objectAtIndex:0];
             Place *placeObj = [self placeFromDict:singleAddress save:NO];
             handlePlace(placeObj);
         }else{
             handleError (nil);
         }

     } failure:^(NSURLRequest *request,
                 NSHTTPURLResponse *response,
                 NSError *error,
                 id JSON) {

         handleError(error);
     }];
    [operation start];
}

- (void)setLocationName:(NSString *)locationName{
    [[TALocationManager sharedInstance] setCurrentUserLocationName:locationName];
}

- (void)fetchRoutesFromCoordinate:(CLLocationCoordinate2D)fromLoction
                     toCoordinate:(CLLocationCoordinate2D)toLocationCoordinate
                         ifSucess:(void(^)(NSArray *routes))handleRoutes
                        ifFailure:(void(^)(NSError *error))handleError{
    
    AFHTTPClient *_httpClient = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:@"http://maps.googleapis.com/"]];
    [_httpClient registerHTTPOperationClass: [AFJSONRequestOperation class]];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:[NSString stringWithFormat:@"%f,%f", fromLoction.latitude, fromLoction.longitude] forKey:@"origin"];
    [parameters setObject:[NSString stringWithFormat:@"%f,%f", toLocationCoordinate.latitude, toLocationCoordinate.longitude] forKey:@"destination"];
    
    [parameters setValue:@"true" forKey:@"alternatives"];
    [parameters setObject:@"true" forKey:@"sensor"];
    
    NSMutableURLRequest *request = [_httpClient requestWithMethod:@"GET"
                                                             path: @"maps/api/directions/json"
                                                       parameters:parameters];
    
    request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    AFHTTPRequestOperation *operation =
    [_httpClient HTTPRequestOperationWithRequest:request
    success:^(AFHTTPRequestOperation *operation, id response) {
        
        NSInteger statusCode = operation.response.statusCode;
        if (statusCode == 200) {
            TALog(@"response: %@",response);
            NSDictionary *jsonObject=[NSJSONSerialization
                                      JSONObjectWithData:response
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];
            
            NSArray *routes = [self parseRoutesFromResponse:jsonObject];
            handleRoutes(routes);
        } else {
            handleRoutes(nil);
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handleError (error);
    }];
    
    [_httpClient enqueueHTTPRequestOperation:operation];
    
}

- (NSArray *)parseRoutesFromResponse:(NSDictionary *)response {
    
    NSArray *routes = [response objectForKey:@"routes"];
    NSMutableArray *routesArray = [NSMutableArray array];
    
    for (NSDictionary *route in routes) {
        if (route) {
            
            NSString *overviewPolyline = [[route objectForKey: @"overview_polyline"] objectForKey:@"points"];
            [routesArray addObject:[self decodePolyLine:overviewPolyline]];;
        }
    }
    return routesArray;
}

- (NSMutableArray *)decodePolyLine:(NSString *)encodedStr {
    NSMutableString *encoded = [[NSMutableString alloc] initWithCapacity:[encodedStr length]];
    [encoded appendString:encodedStr];
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < (len-2)) {
        NSInteger b;

        // CALCULATE LATITUDE
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        
        // CALCULATE LONGITUDE
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    //[encoded release];
    return array;
}

@end