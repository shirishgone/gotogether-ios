//
//  TAFacebookUser.m
//  TravelApp
//
//  Created by shirish on 23/11/12.
//  Copyright (c) 2012 mutualmobile. All rights reserved.
//

#import "TAFacebookUser.h"

@implementation TAFacebookUser

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    
    [encoder encodeObject:self.fullName forKey:@"fullName"];
    [encoder encodeObject:self.gender forKey:@"gender"];
    [encoder encodeObject:self.facebookID forKey:@"facebookID"];
    [encoder encodeObject:self.profileDescription forKey:@"profileDescription"];
    [encoder encodeObject:self.dateOfBirth forKey:@"dateOfBirth"];
    [encoder encodeObject:self.facebookAccessToken forKey:@"facebookAccessToken"];
    [encoder encodeObject:self.profileUrl forKey:@"profileUrl"];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.fullName = [decoder decodeObjectForKey:@"fullName"];
        self.gender = [decoder decodeObjectForKey:@"gender"];
        self.facebookID = [decoder decodeObjectForKey:@"facebookID"];
        self.facebookAccessToken = [decoder decodeObjectForKey:@"facebookAccessToken"];
        self.profileDescription = [decoder decodeObjectForKey:@"profileDescription"];
        self.dateOfBirth = [decoder decodeObjectForKey:@"dateOfBirth"];
        self.profileUrl = [decoder decodeObjectForKey:@"profileUrl"];
    }
    return self;
}

@end
