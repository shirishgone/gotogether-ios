//
//  AMSlideOutNavigationController.h
//  SlideOut
//
//  Created by Andrea on 12/08/12.
//  Copyright (c) 2012 Andrea Mazzini. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AMSlideOutGlobals.h"
#import "TABaseViewController.h"

typedef void (^AMSlideOutBeforeHandler)(void);
typedef void (^AMSlideOutCompletionHandler)(void);

@interface AMSlideOutNavigationController : TABaseViewController
<UITableViewDataSource,
UITableViewDelegate,
UIGestureRecognizerDelegate>

{
	BOOL									_menuVisible;
	__strong UIView*						_overlayView;
	__strong UIBarButtonItem*				_barButton;
	__strong UITapGestureRecognizer*		_tapGesture;
	__strong UIPanGestureRecognizer*		_panGesture;
}

@property (strong, nonatomic)	NSMutableArray*			menuItems;
@property (strong, nonatomic)	UINavigationController*	contentController;
@property (weak, nonatomic)		UIView*					contentView;
@property (strong, nonatomic)	UITableView*			tableView;
@property (nonatomic, readwrite) BOOL shouldSlide;

- (void)toggleMenu;
+ (id)slideOutNavigationWithMenuItems:(NSArray*)items;
+ (id)slideOutNavigation;
- (id)initWithMenuItems:(NSArray*)items;
- (void)setBottomRowWithTitle:(NSString *)title imageName:(NSString *)imageName andDelegate:(id)delegate;

- (void)addViewControllerToLastSection:(UIViewController*)controller tagged:(int)tag withTitle:(NSString*)title andIcon:(NSString*)icon;
- (void)addViewControllerToLastSection:(UIViewController*)controller tagged:(int)tag withTitle:(NSString*)title andIcon:(NSString*)icon beforeChange:(void(^)())before onCompletition:(void(^)())after;

- (void)addViewController:(UIViewController*)controller tagged:(int)tag withTitle:(NSString*)title andIcon:(NSString*)icon toSection:(NSInteger)section;
- (void)addViewController:(UIViewController*)controller tagged:(int)tag withTitle:(NSString*)title andIcon:(NSString*)icon toSection:(NSInteger)section beforeChange:(void(^)())before onCompletition:(void(^)())after;
- (void)addSectionWithTitle:(NSString*)title;
- (void)setBadgeValue:(NSString*)value forTag:(int)tag;

@end
