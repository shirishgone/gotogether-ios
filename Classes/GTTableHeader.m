//
//  GTTableHeader.m
//  goTogether
//
//  Created by shirish on 28/03/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "GTTableHeader.h"
#define kHeaderHeight 30.0

@interface  GTTableHeader()
@end
@implementation GTTableHeader

- (id)initWithTitle:(NSString *)titleString{
    CGRect frame = CGRectMake(0.0, 0.0, 320.0, kHeaderHeight);
    if ((self = [super initWithFrame:frame])) {
        
        [self setTranslatesAutoresizingMaskIntoConstraints:YES];
        [self setBackgroundColor:[UIColor whiteColor]];
        
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.frame];
        [backgroundImageView setImage:[UIImage imageNamed:@"bg_nav_bar.png"]];
        [self addSubview:backgroundImageView];
        
        double headerLabelHeight = 20.0;
        CGRect headerLabelFrame =
        CGRectMake(10.0, (kHeaderHeight - headerLabelHeight)/2.0, 200.0, headerLabelHeight);
        UILabel *headerLabel =
        [[UILabel alloc] initWithFrame:headerLabelFrame];
        
        [headerLabel setTextColor:[UIColor blackColor]];
        [headerLabel setShadowColor:[UIColor whiteColor]];
        [headerLabel setShadowOffset:CGSizeMake(0, 1)];
        [headerLabel setTextAlignment:NSTextAlignmentLeft];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        [headerLabel setFont:kFont_HelveticaNeueBold_14];
        [headerLabel setText:titleString];

        [self addSubview:headerLabel];
    }
    return self;
}

@end
