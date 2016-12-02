//
// This is a "Singleton by Choice" so a develoepr can create and release the object without causing issues.
#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import "GTAnalyticConstants.h"

@interface GTAnalyticsManager : NSObject
+ (GTAnalyticsManager *)sharedInstance;

- (void)logFacebookConnectFailureWithError:(NSError *)error ;
- (void)logRideCreatedWithDistance:(float)distance ;
- (void)logSearchedRideBeforeDays:(NSInteger)daysCount ;
- (void)logNumberOfSeatsOffered:(NSInteger)seatsCount ;

@end
