//
//  AMSlideOutNavigationController.m
//  SlideOut
//
//  Created by Andrea on 12/08/12.
//  Copyright (c) 2012 Andrea Mazzini. All rights reserved.
//

#import "AMSlideOutNavigationController.h"
#import "AMSlideTableCell.h"
#import "AMSlideTableHeader.h"
#import "GTSoundManager.h"
double const kHorizantalSpacing  = 10.0;
double const kVerticalSpacing  = 5.0;

@interface AMSlideOutNavigationController ()
@property (nonatomic, readwrite)float previousSlideValue;
@property (nonatomic, strong) UIView *footerView;
@end

@implementation AMSlideOutNavigationController

@synthesize contentController = _contentController;
@synthesize tableView = _tableView;
@synthesize menuItems = _menuItems;
@synthesize contentView = _contentView;

- (id)initWithMenuItems:(NSArray*)items
{
	self = [super init];
	if (self) {
		_menuVisible = NO;
    
		self.menuItems = [NSMutableArray arrayWithArray:items];
	}
	return self;
}

+ (id)slideOutNavigationWithMenuItems:(NSArray*)items
{
	return [[AMSlideOutNavigationController alloc] initWithMenuItems:items];
}

- (id)init
{
	self = [super init];
	if (self) {
		_menuVisible = NO;
		self.menuItems = [[NSMutableArray alloc] init];
        self.shouldSlide = YES;
	}
	return self;
}

+ (id)slideOutNavigation
{
	return [[AMSlideOutNavigationController alloc] init];
}

- (void)addSectionWithTitle:(NSString*)title
{
	NSMutableDictionary* section = [[NSMutableDictionary alloc] init];
	[section setObject:title forKey:kSOSectionTitle];
	[section setObject:[[NSMutableArray alloc] init] forKey:kSOSection];
	
	[self.menuItems addObject:section];
}

- (void)addViewController:(UIViewController*)controller
                   tagged:(int)tag
                withTitle:(NSString*)title
                  andIcon:(NSString*)icon
                toSection:(NSInteger)section
{
	[self addViewControllerToLastSection:controller
								  tagged:tag
							   withTitle:title
								 andIcon:icon
							beforeChange:nil
						  onCompletition:nil];
}

- (void)addViewController:(UIViewController*)controller
                   tagged:(int)tag
                withTitle:(NSString*)title
                  andIcon:(NSString*)icon
                toSection:(NSInteger)section
             beforeChange:(void(^)())before
           onCompletition:(void(^)())after
{
	if (section < [self.menuItems count]) {
		NSMutableDictionary* item = [[NSMutableDictionary alloc] init];
		[item setObject:controller forKey:kSOController];
		[item setObject:title forKey:kSOViewTitle];
		[item setObject:icon forKey:kSOViewIcon];
		if (before) {
			[item setObject:[before copy] forKey:kSOBeforeBlock];
		}
		if (after) {
			[item setObject:[after copy] forKey:kSOAfterBlock];
		}
		[item setObject:[NSNumber numberWithInt:tag] forKey:kSOViewTag];
		[[[self.menuItems objectAtIndex:section] objectForKey:kSOSection] addObject:item];
	} else {
		NSLog(@"AMSlideOutNavigation: section index out of bounds");
	}
}

- (void)setBottomRowWithTitle:(NSString *)title imageName:(NSString *)imageName andDelegate:(id)delegate{

    CGRect footerFrame = CGRectMake(0.0, 0.0, kSlideValue, kCellHeight);
    
    AMSlideTableHeader *footer = [[AMSlideTableHeader alloc] initWithFrame:footerFrame];
    [footer.titleLabel setText:title];
    [footer.iconImageView setImage:[UIImage imageNamed:imageName]];
    [footer setDelegate:delegate];
    self.footerView = footer;
}

- (void)setBadgeValue:(NSString*)value forTag:(int)tag
{
	for (NSDictionary* section in self.menuItems) {
		for (NSMutableDictionary* item in [section objectForKey:kSOSection]) {
			if ([[item objectForKey:kSOViewTag] intValue] == tag) {
				[item setObject:value forKey:kSOViewBadge];
			}
		}
	}
	// Save and reselect the row after the reload
	NSIndexPath *ipath = [self.tableView indexPathForSelectedRow];
	[self.tableView reloadData];
	[self.tableView selectRowAtIndexPath:ipath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)addViewControllerToLastSection:(UIViewController*)controller tagged:(int)tag withTitle:(NSString*)title andIcon:(NSString*)icon
{
	[self addViewController:controller tagged:tag withTitle:title andIcon:icon toSection:([self.menuItems count]-1)];
}

- (void)addViewControllerToLastSection:(UIViewController*)controller tagged:(int)tag withTitle:(NSString*)title andIcon:(NSString*)icon beforeChange:(void(^)())before onCompletition:(void(^)())after
{
	[self addViewController:controller tagged:tag withTitle:title andIcon:icon toSection:([self.menuItems count]-1) beforeChange:before onCompletition:after];
}

- (void)setContentViewController:(UIViewController *)controller
{
	// Sets the view controller as the new root view controller for the navigation controller
	[self.contentController setViewControllers:[NSArray arrayWithObject:controller] animated:NO];
	self.contentView = self.contentController.view;
	[self.contentView removeFromSuperview];
	[self.view addSubview:self.contentView];
	[self.contentController.topViewController.navigationItem setLeftBarButtonItem:_barButton];
}

- (void)loadView
{    
	UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
	[view setBackgroundColor:kBackground];
	
	// Table View setup
	self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, 320, [[UIScreen mainScreen] bounds].size.height)];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.backgroundColor = kBackground;
    self.tableView.rowHeight = kCellHeight;
    if(self.footerView !=nil){
        [self.tableView setTableFooterView:self.footerView];
    }

	// The content is displayed in a UINavigationController
	self.contentController = [[UINavigationController alloc] init];
	self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    //self.contentView.layer.shadowOffset = CGSizeMake(-10, 0);
    self.contentView.layer.shadowOpacity = 0.4;
    self.contentView.layer.shadowRadius = 10.0;
    self.contentView.clipsToBounds = NO;
	
	/* The transparent overlay view will catch all the user touches in the content area
	 when the slide menu is visible */
	_overlayView = [[UIView alloc] initWithFrame:self.contentController.view.frame];
	_overlayView.userInteractionEnabled = YES;
	_overlayView.backgroundColor = [UIColor clearColor];
	
	[view addSubview:self.tableView];
	
	self.view = view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 	
	[self.tableView setDelegate:self];
	[self.tableView setDataSource:self];
	
    UIImage *menuSlideImage = [UIImage imageNamed:@"menu_icon.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:menuSlideImage forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, menuSlideImage.size.width, menuSlideImage.size.height)];
    [button addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];

	_barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
	
	// Detect when the content recieves a single tap
	_tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[_overlayView addGestureRecognizer:_tapGesture];
	
	// Detect when the content is touched and dragged
	_panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	[_panGesture setMaximumNumberOfTouches:2];
	[_panGesture setDelegate:self];
	[_overlayView addGestureRecognizer:_panGesture];

	[_contentController.view addGestureRecognizer:_panGesture];
	
	// Select the first view controller
	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                animated:NO
                          scrollPosition:UITableViewScrollPositionTop];
    [self.tableView setScrollEnabled:NO];

	[self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void)setMenuItems:(NSArray *)menuItems
{
	// Makes sure to refresh the table data when new items are set
	_menuItems = [NSMutableArray arrayWithArray:menuItems];
	[self.tableView reloadData];
}

#pragma mark Table View delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.menuItems count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[[self.menuItems objectAtIndex:section] objectForKey:kSOSection] count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[self.menuItems objectAtIndex:section] objectForKey:kSOSectionTitle];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString* cellID = @"AMSlideTableCell";
	
	NSDictionary* dict = [[[self.menuItems objectAtIndex:indexPath.section] objectForKey:kSOSection] objectAtIndex:indexPath.row];
	UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
	if (cell == nil) {
		cell = [[AMSlideTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
        [cell.contentView setBackgroundColor:kBackground];
        [cell setBackgroundColor:kBackground];
	}
	
	cell.textLabel.text = [dict objectForKey:kSOViewTitle];
        
	[(AMSlideTableCell*)cell setBadgeText:[dict objectForKey:kSOViewBadge]];
	NSString* image = [dict objectForKey:kSOViewIcon];
	if (image != nil && ![image isEqualToString:@""]) {
		cell.imageView.image = [UIImage imageNamed:image];
	} else {
		cell.imageView.image = nil;
	}

	return cell;
}

//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//	AMSlideTableHeader *header = [[AMSlideTableHeader alloc] init];
//    [header setBackgroundColor:kBackground];
//	header.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
//    return header;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//	NSString* title = [self tableView:tableView titleForHeaderInSection:section];
//	if (title == nil || [title isEqualToString:@""]) {
//		return 0;
//	}
//    return 22.0f;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary* dict = [[[self.menuItems objectAtIndex:indexPath.section] objectForKey:kSOSection] objectAtIndex:indexPath.row];
	
	AMSlideOutBeforeHandler before = [dict objectForKey:kSOBeforeBlock];
	if (before) {
		before();
	}
	[self setContentViewController:[dict objectForKey:kSOController]];
    [self hideSideMenu];
    [self playSounds];
	AMSlideOutBeforeHandler after = [dict objectForKey:kSOAfterBlock];
	if (after) {
		after();
	}
}

- (void)toggleMenu
{
    if (_menuVisible) {
        [self hideSideMenu];
    } else {
        [self showSideMenu];
    }
    [self playSounds];
}

- (void)playSounds{
    if (_menuVisible) {
        [GTSoundManager playSound_closeSlide];

    }else{
        [GTSoundManager playSound_openSlide];
    }
}

- (void)showSideMenu
{
    [UIView animateWithDuration:kSlideAnimationDuration
						  delay:kSlideAnimationDelay
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 // Move the whole NavigationController view aside
						 CGRect frame = self.contentController.view.frame;
						 frame.origin.x = kSlideValue;
						 self.contentController.view.frame = frame;
					 }
                     completion:^(BOOL finished) {
						 // Add the overlay that will receive the gestures
						 [self.contentController.topViewController.view addSubview:_overlayView];
						 _menuVisible = YES;
						 [_barButton setStyle:UIBarButtonItemStyleDone];
					 }];
	
}

- (void)hideSideMenu
{
    // this animates the screenshot back to the left before telling the app delegate to swap out the MenuViewController
    // it tells the app delegate using the completion block of the animation
    [UIView animateWithDuration:kSlideAnimationDuration
						  delay:kSlideAnimationDelay
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 // Move back the NavigationController
						 CGRect frame = self.contentController.view.frame;
						 frame.origin.x = 0;
						 self.contentController.view.frame = frame;
					 }
                     completion:^(BOOL finished) {
						 [_overlayView removeFromSuperview];
						 _menuVisible = NO;
						 [_barButton setStyle:UIBarButtonItemStylePlain];
					 }];
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    // A single tap hides the slide menu
    [self hideSideMenu];
}

/* The following is from 
 http://blog.shoguniphicus.com/2011/06/15/working-with-uigesturerecognizers-uipangesturerecognizer-uipinchgesturerecognizer/ 
 as mentioned by Nick Harris, in his approach to slide-out navigation:
 http://nickharris.wordpress.com/2012/02/05/ios-slide-out-navigation-code/
 */
- (void)handlePan:(UIPanGestureRecognizer *)gesture;
{
    if (_shouldSlide == NO) {
        return;
    }
    
	// The pan gesture moves horizontally the view
    UIView *piece = self.contentController.view;
    [self adjustAnchorPointForGestureRecognizer:gesture];
    
    if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [gesture translationInView:[piece superview]];
        [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y)];
		if (piece.frame.origin.x < 0) {
			[piece setFrame:CGRectMake(0, piece.frame.origin.y, piece.frame.size.width, piece.frame.size.height)];
		}
		if (piece.frame.origin.x > kSlideValueExtended) {
			[piece setFrame:CGRectMake(kSlideValueExtended, piece.frame.origin.y, piece.frame.size.width, piece.frame.size.height)];
		}
        [gesture setTranslation:CGPointZero inView:[piece superview]];
        
        self.previousSlideValue = piece.frame.origin.x;
        NSLog(@"x position: %f",piece.frame.origin.x);
        
    }
    else if ([gesture state] == UIGestureRecognizerStateEnded) {
		// Hide the slide menu only if the view is released under a certain threshold, the threshold is lower when the menu is hidden
		float threshold;
		if (_menuVisible) {
			threshold = kSlideValue;
		} else {
			threshold = kSlideValue / 2;
		}
			
		if (self.contentController.view.frame.origin.x < threshold) {
			[self hideSideMenu];
		} else {
			[self showSideMenu];
		}
	}
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = self.contentController.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	[self setTableView:nil];
	[self setContentController:nil];
	[_overlayView removeGestureRecognizer:_tapGesture];
    [_overlayView removeGestureRecognizer:_panGesture];
	_tapGesture = nil;
	_panGesture = nil;
	_overlayView = nil;
	_barButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
