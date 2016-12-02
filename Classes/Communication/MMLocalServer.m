//
//  MMLocalServer.m
//  goTogether
//
//  Created by Conrad Stoll on 2/14/12.
//  Copyright (c) 2012 Mutual Mobile. All rights reserved.
//

#import "MMLocalServer.h"


@implementation MMLocalServer

+ (NSString*)resourceNameForURN:(NSString*)URN {
    // Return the name for the json file for the given URN
    
    return @"test";
    
    return nil;
}

+ (id)dataForJSONResource:(NSString*)resourceName error:(NSError **)error{
	id data = nil;
    
    NSURL* jsonURL = [[NSBundle mainBundle] URLForResource:resourceName withExtension:@"json"];
    
	if (jsonURL != nil)
	{
        NSError* parsingError = nil;
        NSData *jsonData = [NSData dataWithContentsOfURL:jsonURL options:NSDataReadingUncached error:&parsingError];
        
        if (jsonData != nil) {
            NSError *jsonError;
            data = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&jsonError]; 
            
            if (data == nil) {
                TALog(@"JSON error: %@", jsonError);
                
                if (error != nil)
                    *error = jsonError;
            }
        } else {
            TALog(@"Parsing error: %@", parsingError);
            
            if (error != nil)
                *error = parsingError;
        }
	}
	
	return data;
}

+ (void)simulateServerDelayWithBlock:(void(^)(void))block {
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		block();
	});
}


+ (void)loadJSONResource:(NSString*)resourceName
           responseBlock:(void(^)(NSDictionary* responseData))responseBlock
            failureBlock:(void(^)(NSError* error))failureBlock
{
    
    if (resourceName != nil) {
        NSError *parsingError = nil;
        
        NSDictionary* response = [self dataForJSONResource:resourceName error:&parsingError];
        
        void (^delayBlock)(void) = ^(void) {
            
            if (parsingError != nil)
                failureBlock(parsingError);
            else 
                responseBlock(response);
		};
        
#ifdef INTEGRATION_TESTING
        delayBlock();
#else
		[self simulateServerDelayWithBlock:delayBlock];
#endif
        
    } else {
        NSError *error = [MMRecord errorWithMMRecordCode:MMRecordErrorCodeUndefinedServer description:[NSString stringWithFormat:@"No Resource Name defined in %@'s resourceNameForURN method for the given URN.  Unable to generate response object.", NSStringFromClass(self)]];
        
        failureBlock(error);
    }
}

#pragma mark - Caching

+ (NSURLRequest *)requestWithURN:(NSString *)URN data:(NSDictionary *)data {
    return nil;
}

+ (void)cancelRequestsWithDomain:(id)domain {

}

+ (void)startRequestWithURN:(NSString *)URN 
                       data:(NSDictionary *)data
                      paged:(BOOL)paged
                     domain:(id)domain
                    batched:(BOOL)batched
              dispatchGroup:(dispatch_group_t)dispatchGroup
              responseBlock:(void (^)(id responseObject))responseBlock 
               failureBlock:(void (^)(NSError *error))failureBlock { 
    [self loadJSONResource:[self resourceNameForURN:URN] responseBlock:responseBlock failureBlock:failureBlock];
}


@end
