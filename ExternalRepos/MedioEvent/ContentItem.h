//
//  ContentItem.h
//  MedioEvent
//
//  Created by Toly Pochkin on 3/21/13.
//
//

#import <Foundation/Foundation.h>

@interface ContentItem : NSObject

/// Item Id e.g. "recs@item_id".
@property (nonatomic, copy) NSString* itemId;
/// Type of item e.g. "APP".
@property (nonatomic, copy) NSString* type;
/// Title of item. For rendering in the end user UI. e.g. "Lotza"
@property (nonatomic, copy) NSString* title;
/// Short description of the item. For rendering in the end user UI. e.g. Lotza is the best app for finding
/// personalized deals.
@property (nonatomic, copy) NSString* shortDescription;
/// Long description of the item. For rendering in end user UI. e.g. Lotza is the best app for finding
/// personalized deals from top daily deal providers and tracking everything you've bought in one place.
@property (nonatomic, copy) NSString* longDescription;
/// List of categories this item belongs to. e.g. "SHOPPING"
@property (nonatomic, strong) NSArray* categories;
/// Timestamp of when this item was last updated. e.g. "2013-03-06 00:23:54.0"
@property (nonatomic, copy) NSString* updated;
/// Expiration timestamp
@property (nonatomic, copy) NSString* expirationDate;
/// "Star" Rating of the item from 0-5. For rendering in the end user UI. e.g. "4.4502997"
@property (nonatomic, assign) NSNumber* rating;
/// Price
@property (nonatomic, copy) NSString* price;
/// Price unit
@property (nonatomic, copy) NSString* priceUnit;
/// URI to the icon item
@property (nonatomic, copy) NSString* iconURI;
/// URI to the small icon item
@property (nonatomic, copy) NSString* smallImageURI;
/// URI to the large icon item
@property (nonatomic, copy) NSString* largeImageURI;
/// URI to navigate to when user clicks on items. e.g. "http://www.medio.com"
@property (nonatomic, copy) NSString* targetURI;
/// Rating count for the item e.g. how many people rated this item.
@property (nonatomic, copy) NSString* ratingCount;
/// The placement ID for this item. Used for rendering.
@property (nonatomic, copy) NSString* placementId;
/// The presentation for this item. Used for rendering.
@property (nonatomic, copy) NSString* presentation;
/// Some value that relates to where this item should be rendered. How this is interpreted is entirely up to
/// rendering app. e.g. "PRESCRIBED"
@property (nonatomic, copy) NSString* presentationMethod;
/// The ID of the request that returned this item.
@property (nonatomic, copy) NSString* requestID;
/// Provider tag for the item.
@property (nonatomic, copy) NSString* providerTag;
/// Map of attribute name-value pairs found in channel manager item.
@property (nonatomic, copy) NSArray* attributes;

/// Initialize content item with id.
- (id)initWithItemId:(NSString*)itemId;

@end

