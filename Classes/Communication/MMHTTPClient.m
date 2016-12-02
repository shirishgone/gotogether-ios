//
//  MMHTTPClient.m
//  goTogether
//
//  Created by Conrad Stoll on 4/16/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMHTTPClient.h"

#import "AFJSONRequestOperation.h"
#import "AFNetworkActivityIndicatorManager.h"

@implementation MMHTTPClient

SYNTHESIZE_SINGLETONBYCHOICE_FOR_CLASS(MMHTTPClient)

+ (NSString *)baseUrlForType:(GTServerType) serverType {
    NSString *serverUrl = nil;
#ifdef GT_PUBLIC_RELEASE
    serverUrl =  kRedHotApi_liveBaseUrl_production;
#else
    serverUrl =  kRedHotApi_liveBaseUrl_development;
#endif
    
    return (serverType == serverType_localServer)? kRedHotApi_localBaselUrl:serverUrl;
}

+ (NSURL *)baseURL{
    NSURL *baseURL = [NSURL URLWithString:[MMHTTPClient baseUrlForType:serverType_liveServer]];
    return baseURL;
}

+ (BOOL)isError:(id)error{
    
    if ([error isKindOfClass:[NSDictionary class]]) {
        if ([[error allKeys] count] > 0) {
            return YES;
        }
    }
    
    return NO;
}

+ (NSError *)errorObject:(id)error{
    
    NSError *errorObject = nil;

    NSInteger errorCode = [[error valueForKey:@"code"] integerValue];
    NSString *errorDescription = [error valueForKey:@"description"];
    NSString *domain = [error valueForKey:@"domain"];
    
    errorObject = [NSError errorWithDomain:domain
                                    code:errorCode
                                userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:@"errorDescription"]];
   
    return errorObject;
}
@end
