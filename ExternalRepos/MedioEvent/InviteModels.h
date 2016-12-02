//
//  InviteModels.h
//  MedioEventSpitfire
//
//  Created by Toly Pochkin on 2/27/13.
//  Copyright (c) 2013 Medio, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MedioEventInvites.h"


#pragma mark - RegInviteResponse declaration

/// ------------------------------------------------------------------------------------------------------------------
/// RegInviteResponse model
/// ------------------------------------------------------------------------------------------------------------------
@interface RegInviteResponse : NSObject

@property (nonatomic, copy) NSString* inviteId;
@property (nonatomic, copy) NSString* message;
@property (nonatomic, copy) NSString* status;
@property (nonatomic, copy) NSString* subject;
@property (nonatomic, copy) NSNumber* inviteTime;
@property (nonatomic, copy) NSString* url;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSNumber* claimAvailableCount;
@property (nonatomic, copy) NSNumber* installCount;

/// Initialize model with NSDictionary received as JSON response.
- (id)initWithDictionary:(NSDictionary*)dict;

@end


#pragma mark - Contact item

typedef enum _ContactType
{
    kContactType_Message,
    kContactType_Email,
    kContactType_Twitter
} ContactType;

@interface ContactItem : NSObject

@property (nonatomic, assign) ContactType type;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* value;

- (id)initWithType:(ContactType)type name:(NSString*)name value:(NSString*)value;

@end


#pragma mark - ConfirmInviteResponse declaration


/// ------------------------------------------------------------------------------------------------------------------
/// RegInviteResponse model
/// ------------------------------------------------------------------------------------------------------------------
@interface ConfirmInviteResponse : NSObject

/// Initialize model with NSDictionary received as JSON response.
- (id)initWithDictionary:(NSDictionary*)dict;

@end



/// ------------------------------------------------------------------------------------------------------------------
/// CreateFacebookInviteResponse model
/// ------------------------------------------------------------------------------------------------------------------
@interface CreateFacebookInviteResponse : NSObject

/// Initialize model with NSDictionary received as JSON response.
- (id)initWithDictionary:(NSDictionary*)dict;

@end


#pragma mark - SyncResponse declaration


/// ------------------------------------------------------------------------------------------------------------------
/// SyncResponse model
/// ------------------------------------------------------------------------------------------------------------------
@interface SyncResponse : NSObject

/// List of rewards
@property (nonatomic, strong) NSArray* rewards;
/// List of invites
@property (nonatomic, strong) NSArray* invites;

/// Initialize model with NSDictionary received as JSON response.
- (id)initWithDictionary:(NSDictionary*)dict;

@end



/// ------------------------------------------------------------------------------------------------------------------
/// DeleteInviteResponse model
/// ------------------------------------------------------------------------------------------------------------------
@interface DeleteInviteResponse : NSObject

/// Initialize model with NSDictionary received as JSON response.
- (id)initWithDictionary:(NSDictionary*)dict;

@end


/// ------------------------------------------------------------------------------------------------------------------
/// AcceptRewardResponse model
/// ------------------------------------------------------------------------------------------------------------------
@interface AcceptRewardResponse : NSObject

/// Initialize model with NSDictionary received as JSON response.
- (id)initWithDictionary:(NSDictionary*)dict;

@end



/// ------------------------------------------------------------------------------------------------------------------
/// FacebookUpdateUserInfoResponse model
/// ------------------------------------------------------------------------------------------------------------------
@interface FacebookUpdateUserInfoResponse : NSObject

/// Initialize model with NSDictionary received as JSON response.
- (id)initWithDictionary:(NSDictionary*)dict;

@end




/// ------------------------------------------------------------------------------------------------------------------
/// AcceptedInvite model
/// ------------------------------------------------------------------------------------------------------------------
@interface AcceptedInvite : NSObject

@property (nonatomic, copy) NSString* inviteId;
@property (nonatomic, copy) NSNumber* claimCount;

- (id)initWithInviteId:(NSString*)inviteId claimCount:(NSNumber*)claimCount;
- (NSDictionary*)toDictionary;

@end
