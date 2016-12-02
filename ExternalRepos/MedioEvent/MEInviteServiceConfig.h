//
//  InviteServiceConfig.h
//  MedioEvent
//
//  Created by Toly Pochkin on 11/21/13.
//  Copyright 2011-2013 Medio. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 * Invite Service configuration properties.
 */
@interface MEInviteServiceConfig : NSObject

/** Dashboard's (main Invit Service page) background image. */
@property (strong) UIImage* dashboardBackgroundImage;
/** Dashboard's reward title font. */
@property (strong) UIFont* dashboardRewardTitleFont;
/** Dashboard's reward title text color. */
@property (strong) UIColor* dashboardRewardTitleTextColor;
/** Dashboard's reward background color. */
@property (strong) UIColor* dashboardRewardBackgroundColor;
/** Dashboard's reward description font. */
@property (strong) UIFont* dashboardRewardDescriptionFont;
/** Dashboard's reward description text color. */
@property (strong) UIColor* dashboardRewardDescriptionTextColor;
/** Dashboard's reward row height. */
@property (assign) CGFloat dashboardRewardRowHeight;
/** Dashboard's reward row height for landscape mode (has precedence over dashboardRewardRowHeight property). */
@property (assign) CGFloat dashboardRewardLandscapeRowHeight;
/** Dashboard's reward row height for portrait mode (has precedence over dashboardRewardRowHeight property). */
@property (assign) CGFloat dashboardRewardPortraitRowHeight;
/**
 * Dashboard's reward image width. Width AND Height MUST be set for this to have any effect.
 * Image will be scaled to fill up the set width and height while preserving aspect ratio.
 * This means you may have some horizontal or vertical white space.
 */
@property (assign) CGFloat dashboardRewardImageWidth;
/**
 * Dashboard's reward image height. Width AND Height MUST be set for this to have any effect.
 * Image will be scaled to fill up the set width and height while preserving aspect ratio.
 * This means you may have some horizontal or vertical white space.
 */
@property (assign) CGFloat dashboardRewardImageHeight;
/** Dashboard's row height for New Invite cells, e.g. "Contacts", "Facebook". */
@property (assign) NSUInteger dashboardNewInviteRowHeight;
/** Dashboard's image for "Contact" cell. */
@property (copy) NSString* dashboardNewInviteContactsImageName;
/** Dashboard's image for "Facebook" cell. */
@property (copy) NSString* dashboardNewInviteFacebookImageName;
/** Dashboard's New Invite title font. */
@property (strong) UIFont* dashboardNewInviteTitleFont;
/** Dashboard's New Invite title text color. */
@property (strong) UIColor* dashboardNewInviteTitleTextColor;
/** Dashboard's New Invite background color. */
@property (strong) UIColor* dashboardNewInviteBackgroundColor;
/** Dashboard's section title text color (works only for iOS 6.0 and above). */
@property (strong) UIColor* dashboardSectionTitleTextColor;
/** Dashboard's section title background color (works only for iOS 6.0 and above). */
@property (strong) UIColor* dashboardSectionTitleBackgroundColor;
/** Dashboard's section title font(works only for iOS 6.0 and above). */
@property (strong) UIFont* dashboardSectionTitleFont;
/** Dashboard's section footer text color (works only for iOS 6.0 and above). */
@property (strong) UIColor* dashboardSectionFooterTextColor;
/** Dashboard's section footer background color (works only for iOS 6.0 and above). */
@property (strong) UIColor* dashboardSectionFooterBackgroundColor;
/** Dashboard's section footer font (works only for iOS 6.0 and above). */
@property (strong) UIFont* dashboardSectionFooterFont;
/** Dashboard's Invite title font. */
@property (strong) UIFont* dashboardInviteTitleFont;
/** Dashboard's Invite detail font. */
@property (strong) UIFont* dashboardInviteDetailsFont;
/** Dashboard's Invite title text color. */
@property (strong) UIColor* dashboardInviteTitleTextColor;
/** Dashboard's Invite title text color. */
@property (strong) UIColor* dashboardInviteDetailsTextColor;
/** Dashboard's Invite background color. */
@property (strong) UIColor* dashboardInviteBackgroundColor;
/** Dashboard's Invite row height for contacts. */
@property (assign) NSUInteger dashboardInviteRowHeight;

@end
