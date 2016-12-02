//
//  ContentManager.h
//  MedioEvent
//
//  Created by Toly Pochkin on 3/23/13.
//
//

#import <Foundation/Foundation.h>
#import "ContentItem.h"


/**
 * Different types of content dispositions. Cheat a bit and keep them lower case since that is how we use it for
 * Channel Manager query parameters.
 */
typedef enum _Disposition {
    /** User clicked on content item to view detail page. */
    kDisposition_Click,
    /** User accepted a content item e.g. clicked "buy". */
    kDisposition_Accept,
    /** User declined a content item e.g. clicked "don't show me again" or "dismissed item without buying". */
    kDisposition_Decline
} Disposition;


typedef void (^ContentItemsReceiver)(NSArray* contentItems, NSError* error);


@class MedioEvent;


/// ------------------------------------------------------------------------------------------------------------------
/// Content options.
/// ------------------------------------------------------------------------------------------------------------------
@interface ContentOptions : NSObject

@property (nonatomic, copy) NSArray* placements;
@property (nonatomic, copy) NSString* region;
@property (nonatomic, copy) NSString* postalCode;
@property (nonatomic, copy) NSArray* contextItems;
@property (nonatomic, copy) NSString* currentCatalog;
@property (nonatomic, copy) NSString* currentCategory;
@property (nonatomic, copy) NSString* requestId;

@end


/// ------------------------------------------------------------------------------------------------------------------
/// Content manager.
/// ------------------------------------------------------------------------------------------------------------------
@interface ContentManager : NSObject <NSURLConnectionDelegate>

@property (nonatomic, copy) NSArray* contentItems;

+ (void)setContentManagerBaseURL:(NSString*)baseURL;

/// Class constructor.
- (id)initWithMedioEvent:(MedioEvent*)medioEvent
                     org:(NSString*)org
                 channel:(NSString*)channel
                  apiKey:(NSString*)apiKey;

/**
 * You must call this method to prefetch content prior to calling {@link getContentItems}. The content is fetched in
 * the background and may take some time before {@link getContentItems} will return valid content. The time it takes
 * depends on the device's data network connection conditions. We recommend calling this method in your main root
 * activity so that fresh content is retrieved each time your app is started at the main root activity.
 *
 * @param context
 *            Context is optional. {@code null} allowed. For the minimal Content API configuration, there are no
 *            contexts specified. If we have specific contexts configured for a customer, the customer may specify
 *            them here
 * @param options
 *            is optional. {@code null} allowed. See {@link ContentOptions}.
 * @param maxItems
 *            must be greater than 0. Maximum number of content items to fetch. Number of content items fetched may
 *            be less than this number.
 */
- (BOOL)requestContentItemsWithContentOptions:(ContentOptions*)contentOptions
                                      context:(NSString*)context
                                     maxItems:(int)maxItems
                                    withBlock:(ContentItemsReceiver)contentItemsReceiver;
/**
 * Post a disposition (click, accept, decline) to Channel Manager against a specific item.
 *
 * @param disposition
 *            Disposition enum value.
 * @param contentItem
 *            Content item.
 */
- (BOOL)postDisposition:(Disposition)disposition contentItem:(ContentItem*)contentItem;

@end
