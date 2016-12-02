//
//  MMHTTPClient.h
//  goTogether
//
//  Created by Conrad Stoll on 4/16/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "AFHTTPClient.h"

@interface MMHTTPClient : AFHTTPClient

SYNTHESIZE_SINGLETONBYCHOICE_HEADER_FOR_CLASS(MMHTTPClient)
+ (NSURL *)baseURL;
+ (NSString *)baseUrlForType:(GTServerType) serverType;
+ (BOOL)isError:(id)error;
+ (NSError *)errorObject:(id)error;

@end
