//
//  TADateTimePicker.h
//  TravelApp
//
//  Created by shirish on 24/11/12.
//  Copyright (c) 2012 mutualmobile. All rights reserved.
//


#import <UIKit/UIKit.h>

#define MyDateTimePickerHeight 260

@interface TADateTimePicker : UIView

@property (nonatomic, assign, readonly) UIDatePicker *picker;

- (id)initForDateOfBirthWithFrame:(CGRect) frame;
- (void) setMode: (UIDatePickerMode) mode;
- (void) setHidden: (BOOL) hidden animated: (BOOL) animated;
- (void) addTargetForDoneButton: (id) target action: (SEL) action;

@end
