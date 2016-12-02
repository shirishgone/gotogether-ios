//
//  GTVerifications.m
//  goTogether
//
//  Created by shirish on 16/03/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "GTVerifications.h"
#import "AFNetworking.h"
#import "HTMLParser.h"

//http://tracevehicle.bharatiyamobile.com/Trace_Vehicle.php?vehicleno1=MH&vehicleno2=04&vehicleno3=AX&vehicleno4=8870&vehicleno=MH-04+AX-8870

@implementation GTVerifications
+ (void)verifyVehicle:(Vehicle *)vehicle
               sucess:(void (^)(BOOL verified))handleSuccess
              failure:(void (^)(NSError *error))handleFailure{
    
    
//    "http://indiatrace.com/trace-vehicle-location/trace-vehicle-number.php"
    
    
    NSString *urlString = nil;
//    [NSString stringWithFormat:@"http://tracevehicle.bharatiyamobile.com/Trace_Vehicle.php?vehicleno=%@-%@+%@-%@",
//     [vehicle stateCode],
//     [vehicle districtCode],
//     [vehicle uniqueCharacters],
//     [vehicle uniqueNumber]
//     ];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSString *responseString  = [[NSString alloc] initWithData:[NSData dataWithData:responseObject]
                                                          encoding:NSStringEncodingConversionExternalRepresentation];
        
        TALog(@"responseString: %@",responseString);
        NSError *error = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:responseString
                                                          error:&error];
        
        if (error) {
            NSLog(@"Error: %@", error);
            return;
        }
        HTMLNode *bodyNode = [parser body];
        TALog(@"bodyNode: %@",bodyNode);

        HTMLNode *headNode = [parser head];
        TALog(@"headNode: %@",headNode);
        
        HTMLNode *htmlNode = [parser html];
        TALog(@"htmlNode: %@",htmlNode);
        
        HTMLNode *docNode = [parser doc];
        TALog(@"docNode: %@",docNode);
        
//        NSArray *inputNodes = [bodyNode findChildTags:@"div"];
//        for (HTMLNode *node in inputNodes) {
//            if ([[node getAttributeNamed:@"class"] isEqualToString:@"mobile"]) {
//                NSLog(@"%@", [node rawContents]); //Answer to second question
//            }
//        }
//        [parser release];
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@",error);
    }];
    [requestOperation start];
    
    
}
@end
