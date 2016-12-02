//
//  AMSlideTableCell.m
//  SlideOut
//
//  Created by Andrea on 14/08/12.
//  Copyright (c) 2012 Andrea Mazzini. All rights reserved.
//

#import "AMSlideTableCell.h"
#import "AMSlideOutGlobals.h"

#define kBadgeFont		[UIFont fontWithName:@"Helvetica" size:12]
#define kAnimationDistance kSlideValueExtended - kSlideValue

@implementation AMSlideTableCell

@synthesize badge = _badgeValue;
@synthesize badgeNumber = _badgeNumber;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSelectedStateBackground];
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.textLabel.textColor = kCellFontColor;
		self.textLabel.shadowOffset = CGSizeMake(0, 0);
		self.textLabel.shadowColor = kFontShadowColor;
		self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        self.textLabel.textAlignment = NSTextAlignmentCenter;

		self.badge = [[UILabel alloc] init];
		
		[self addSubview:self.badge];
    }
    return self;
}


- (void)layoutSubviews
{
	if (self.imageView.image) {
        
        CGSize imageSize = self.imageView.image.size;
		self.imageView.frame = CGRectMake(kImageViewXOffset , kImageViewYOffset, imageSize.width, imageSize.height);
        self.imageView.center = CGPointMake(kImageViewXCenter, self.imageView.center.y);
		self.textLabel.frame = CGRectMake(kTextLabelXOffset , kTextLabelYOffset, kTextLabelWidth, kTextLabelHeight);
	} else {
		self.textLabel.frame = CGRectMake(kTextLabelXOffset , kTextLabelYOffset, kTextLabelWidth, kTextLabelHeight);
	}
	
	// Set badge properties
	self.badge.font = kBadgeFont;
	self.badge.textColor = kCellFontColor;
	self.badge.adjustsFontSizeToFitWidth = YES;
	self.badge.textAlignment = NSTextAlignmentCenter;
	self.badge.opaque = YES;
	self.badge.backgroundColor = [UIColor clearColor];
	self.badge.shadowOffset = CGSizeMake(0, 1);
	self.badge.shadowColor = kFontShadowColor;
	
	self.badge.layer.cornerRadius = 8;
	self.badge.layer.backgroundColor = [[UIColor blackColor] CGColor];
}

- (void)setBadgeText:(NSString*)text
{
    self.badgeNumber = text;
	if (text == nil || [text isEqualToString:@""]) {
		[self.badge setAlpha:0];
	} else {
		CGSize fontSize = [text sizeWithFont:kBadgeFont];
		CGRect badgeFrame = CGRectMake(kBadgeXOffset,
                                       kBadgeYOffset,
                                       fontSize.width + 15.0,
                                       kBadgeHeight);
        
		self.badge.frame = badgeFrame;
		self.badge.text = text;
		[self.badge setAlpha:1];
	}
}

- (void)addCircleForPreselectedState{

    UIView* view =
    [[UIView alloc] initWithFrame:
     CGRectMake(self.frame.origin.x + 10,self.frame.origin.y + 15, 75, 75)];
    
    [view setContentMode:UIViewContentModeScaleAspectFill];
    view.layer.cornerRadius = view.frame.size.width / 2.0;
    view.layer.masksToBounds = YES;
    view.layer.borderWidth = 0.75;
    view.layer.borderColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5].CGColor;
	[view setBackgroundColor:kBackground];

    [self.contentView addSubview:view];
    [self sendSubviewToBack:view];
}

- (void)addSelectedStateBackground{

    UIView* view =
    [[UIView alloc] initWithFrame:
     CGRectMake(self.frame.origin.x + 10,self.frame.origin.y + 15, 75, 75)];
    
    [view setContentMode:UIViewContentModeScaleAspectFill];
    view.layer.cornerRadius = view.frame.size.width / 2.0;
    view.layer.masksToBounds = YES;
    view.layer.borderWidth = 0.75;
    view.layer.borderColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5].CGColor;
	[view setBackgroundColor:kSelectionBackground];
	self.selectedBackgroundView = view;
}

/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


- (void)drawRect:(CGRect)aRect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(context, kCellBackground);
	CGContextFillRect(context, self.bounds);
	
	CGContextSetStrokeColorWithColor(context, kUpperSeparator);
    CGContextBeginPath(context);
	CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.bounds.size.width, 0);
    CGContextStrokePath(context);
	
	CGContextSetStrokeColorWithColor(context, kLowerSeparator);
    CGContextBeginPath(context);
	CGContextSetLineWidth(context, 1.0);
    CGContextMoveToPoint(context, 0, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextStrokePath(context);
}
 */
@end
