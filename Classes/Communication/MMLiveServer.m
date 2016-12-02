//
//  MMLiveServer.m
//  goTogether
//
//  Created by Conrad Stoll on 2/14/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMLiveServer.h"

#import "MMHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import <objc/runtime.h>

@interface AFJSONRequestOperation (MMLiveServer)

@property (nonatomic, retain) id requestOperationDomain;

- (id)requestOperationDomain;
- (void)setRequestOperationDomain:(id)domain;

@end

@implementation MMLiveServer

+ (void)cancelRequestsWithDomain:(id)domain {
    // By default this will cancel any method started by a class of the same type as domain.  This can be implemented in other ways if desired.
    
    MMHTTPClient *client = [MMHTTPClient sharedMMHTTPClient];
    
    if (domain) {
        for (NSOperation *operation in [client.operationQueue operations]) {
            if (![operation isKindOfClass:[AFJSONRequestOperation class]]) {
                continue;
            }
            
            Class domainClass = [domain class];
            
            if ([[(AFJSONRequestOperation*)operation requestOperationDomain] isEqualToString:NSStringFromClass(domainClass)]) {
                [operation cancel];
            }
        }
    }
}

+ (void)startRequestWithURN:(NSString *)URN 
                       data:(NSDictionary *)data
                      paged:(BOOL)paged
                     domain:(id)domain
                    batched:(BOOL)batched
              dispatchGroup:(dispatch_group_t)dispatchGroup
              responseBlock:(void (^)(id responseObject))responseBlock 
               failureBlock:(void (^)(NSError *error))failureBlock { 
    NSURLRequest *request = [self requestWithURN:URN data:data];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        responseBlock(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {        
        NSDictionary *data = JSON;
        NSDictionary *errorDict = [data valueForKey:@"error"];
        NSInteger errorCode = [[errorDict valueForKey:@"code"] intValue];
        
        if (errorCode == 1010) {
            if (self.sessionTimeoutBlock) {                
                self.sessionTimeoutBlock(^{
                    [self startRequestWithURN:URN data:data paged:paged domain:domain batched:batched dispatchGroup:dispatchGroup responseBlock:responseBlock failureBlock:failureBlock];
                });
            }
        }
        
        failureBlock(error);
    }];
        
    if (domain) {
        // By default this uses uses the type of domain.  This can be implemented in other ways if desired.
        Class domainClass = [domain class];
        
        [operation setRequestOperationDomain:NSStringFromClass(domainClass)];
    }
    
    [[MMHTTPClient sharedMMHTTPClient] enqueueHTTPRequestOperation:operation];
}

#pragma mark - Paging

+ (Class)pageManagerClass {
    return [MMLiveServerPageManager class];
}


#pragma mark - Caching

+ (NSURLRequest *)requestWithURN:(NSString *)URN data:(NSDictionary *)data {
    NSString* newURN = [URN stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *newData = data;
    
    NSMutableURLRequest *baseRequest = [[MMHTTPClient sharedMMHTTPClient] requestWithMethod:@"GET" path:newURN parameters:newData];
    return baseRequest;
}

@end


@interface MMLiveServerPageManager ()

@end

@implementation MMLiveServerPageManager

- (id)initWithResponseObject:(NSDictionary *)dict requestURN:(NSString *)requestURN requestData:(NSDictionary *)requestData recordClass:(Class)recordClass {
    self = [super initWithResponseObject:dict requestURN:requestURN requestData:requestData recordClass:recordClass];
    if (self) {
        
    }
    
    return self;
}

- (NSString*)nextPageURN {    
    return nil;
}

- (NSString*)previousPageURN {
    return nil;
}

- (NSInteger)totalResultsCount {
    return 0;
}

- (NSInteger)resultsPerPage {
    return 0;
}

- (NSInteger)currentPageIndex {
    return 0;
}

@end


@implementation AFJSONRequestOperation (MMLiveServer)

- (id)requestOperationDomain {
    return objc_getAssociatedObject(self, @"MMRecord_recordClassName");
}

- (void)setRequestOperationDomain:(id)domain {
    objc_setAssociatedObject(self,  @"MMRecord_recordClassName", domain, OBJC_ASSOCIATION_RETAIN_NONATOMIC);    
}

@end
