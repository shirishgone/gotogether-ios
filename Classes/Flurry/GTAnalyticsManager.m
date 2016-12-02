
#import "GTAnalyticsManager.h"
#import <Parse/Parse.h>

@implementation GTAnalyticsManager

static GTAnalyticsManager *sharedInstance = nil;

#pragma mark -
#pragma mark Singleton By Choice Methods
+ (id)sharedInstance{
    
    @synchronized([GTAnalyticsManager class])
    {
        if (!sharedInstance){
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
    return nil;
}

#pragma mark - events

- (void)logFacebookConnectFailureWithError:(NSError *)error {

    NSString *codeString = [NSString stringWithFormat:@"%d", [error code]];
    [PFAnalytics trackEvent:@"FacebookConnectError" dimensions:@{ @"code": codeString }];
}


- (void)logRideCreatedWithDistance:(float)distance {

    [PFAnalytics trackEvent:@"post_ride"
                 dimensions:@{ @"distance": [NSString stringWithFormat:@"%f",distance]}];
}

- (void)logSearchedRideBeforeDays:(NSInteger)daysCount {
    
    [PFAnalytics trackEvent:@"search_ride"
                 dimensions:@{ @"searched_days_before": [NSString stringWithFormat:@"%d",daysCount]}];

}

- (void)logNumberOfSeatsOffered:(NSInteger)seatsCount {
    
    [PFAnalytics trackEvent:@"seats_offered"
                 dimensions:@{ @"count": [NSString stringWithFormat:@"%d",seatsCount] }];

}

@end