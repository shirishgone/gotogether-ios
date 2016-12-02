//
//  TADateTimePicker.m
//  TravelApp
//
//  Created by shirish on 24/11/12.
//  Copyright (c) 2012 mutualmobile. All rights reserved.
//

#import "TADateTimePicker.h"
#import "UIToolbar+GTExtensions.h"


#define MyDateTimePickerPickerHeight 216
#define MyDateTimePickerToolbarHeight 44

@interface  TADateTimePicker()

@property (nonatomic, assign, readwrite) UIDatePicker *picker;
@property (nonatomic, assign) CGRect originalFrame;

@property (nonatomic, assign) id doneTarget;
@property (nonatomic, assign) SEL doneSelector;

- (void) donePressed;

@end


@implementation TADateTimePicker

@synthesize picker = _picker;
@synthesize originalFrame = _originalFrame;

@synthesize doneTarget = _doneTarget;
@synthesize doneSelector = _doneSelector;

- (id) initWithFrame: (CGRect) frame {
    if ((self = [super initWithFrame: frame])) {
        self.originalFrame = frame;
        [self setupDatePicker];
    }
    return self;
}

- (id)initForDateOfBirthWithFrame:(CGRect) frame {
    if ((self = [super initWithFrame: frame])) {
        self.originalFrame = frame;
        [self setupDatePicker];
        self.picker.minimumDate = nil;
    }
    return self;
}

- (void)setupDatePicker {
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat width = self.bounds.size.width;
    UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame: CGRectMake(0, MyDateTimePickerToolbarHeight, width, MyDateTimePickerPickerHeight)];
    picker.minimumDate = [NSDate date];
    [picker setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:picker];
    
    UIToolbar *toolbar =
    [UIToolbar GTToolBarWithDoneButtonWithDelegate:self andSelector:@selector(donePressed)];
    [self addSubview:toolbar];
    
    self.picker = picker;
}

- (void) setMode: (UIDatePickerMode) mode {
    self.picker.datePickerMode = mode;
}

- (void) donePressed {
    if (self.doneTarget) {
        [self.doneTarget performSelector:_doneSelector withObject:self.picker.date];
    }
}

- (void) addTargetForDoneButton: (id) target action: (SEL) action {
    self.doneTarget = target;
    self.doneSelector = action;
}

- (void) setHidden: (BOOL) hidden animated: (BOOL) animated {
    CGRect newFrame = self.originalFrame;
    newFrame.origin.y += hidden ? MyDateTimePickerHeight : 0;
    if (animated) {
        [UIView beginAnimations: @"animateDateTimePicker" context: nil];
        [UIView setAnimationDuration:2.0];
        [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
        
        self.frame = newFrame;
        
        [UIView commitAnimations];
    } else {
        self.frame = newFrame;      
    }
}

@end
