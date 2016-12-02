//
//  NSDate+GTExtensions.h
//  goTogether
//
//  Created by shirish on 11/06/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface NSDate (GTExtensions)
+ (NSString *)dateStringForDate:(NSDate *)date;
+ (NSString *)display_dataStringForDate:(id)date;

+ (NSDateFormatter *)display_dateFormatter;
+ (NSDateFormatter *)dateFormatter;

+ (NSDate *)dateFromString:(NSString *)dateString;
    
+ (NSString *)display_onlyDateStringFromDate:(NSDate *)date;
+ (NSString *)display_dayOfTheWeekFromDate:(NSDate *)date;
+ (NSString *)display_onlyTimeStringFromDate:(NSDate *)date;
+ (BOOL)isToday:(NSDate*)date;

+ (NSString *)display_dateStringForSearchDate:(id)date;
+ (NSString *)display_dateOfBirthStringFromDate:(NSDate *)date;
+ (NSString *)dateStringForEvent:(Event *)event;

- (NSInteger)differenceInDaysToDate:(NSDate *)date;

+ (NSString *)dateOfBirthStringFromDate:(id)date;
+ (NSDate *)dateFromDateOfBirthString:(NSString *)dateOfBirthString;
- (NSString *)ageString;

@end
