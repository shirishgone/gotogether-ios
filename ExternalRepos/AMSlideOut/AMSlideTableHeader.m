//
//  AMSlideTableHeader.m
//  SlideOut
//
//  Created by Andrea on 14/08/12.
//  Copyright (c) 2012 Andrea Mazzini. All rights reserved.
//

#import "AMSlideTableHeader.h"
#import "AMSlideOutGlobals.h"

@implementation AMSlideTableHeader

@synthesize titleLabel = _titleLabel;
@synthesize iconImageView = _iconImageView;

- (id)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])) {
        [self setupTitleLabel];
        [self setupIconView];
        [self setupTapGestureRecognizer];
    }
    return self;
}

- (void)setupTapGestureRecognizer{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(tapGestureRecognized:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
}
- (void)setupIconView{
 
    self.iconImageView = [[UIImageView alloc]
                          initWithFrame:CGRectZero];
    
    [_iconImageView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_iconImageView];
}


- (void)layoutSubviews{
    UIImage *iconImage = self.iconImageView.image;
    CGRect imageFrame = CGRectMake(kImageViewXOffset , kImageViewYOffset, iconImage.size.width, iconImage.size.height);
    [self.iconImageView setFrame:imageFrame];
}

- (void)setupTitleLabel{

    CGRect titleFrame = CGRectMake(kTextLabelXOffset , kTextLabelYOffset, kTextLabelWidth, kTextLabelHeight);
    self.titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    
    self.titleLabel.backgroundColor = kBackground;
    self.titleLabel.textColor = kCellFontColor;
    self.titleLabel.shadowOffset = CGSizeMake(0, 0);
    self.titleLabel.shadowColor = kFontShadowColor;
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_titleLabel];

}
/*
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
- (void)tapGestureRecognized:(id)sender{
    if ([_delegate respondsToSelector:@selector(didTapOnTableHeader)]) {
        [_delegate didTapOnTableHeader];
    }
}
@end
