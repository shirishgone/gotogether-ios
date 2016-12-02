//
//  NSDate+GTExtensions.m
//  goTogether
//
//  Created by shirish on 11/06/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "NSDate+GTExtensions.h"

@implementation NSDate(GTExtensions)

// String from Date
+ (NSString *)dateStringForDate:(NSDate *)date{
    NSString *resultString = [[self dateFormatter] stringFromDate:date];
    return resultString;
}

+ (NSDateFormatter *)display_dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM, hh:mm a"];
    return dateFormatter;
}

// Date formatters
+ (NSDateFormatter *)dateFormatter {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    return dateFormatter;
}

+ (NSDateFormatter *)display_searchDateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM YYYY"];
    return dateFormatter;
}

+ (NSString *)display_dateStringForSearchDate:(id)date {
    NSString *dateString = [[self display_searchDateFormatter] stringFromDate:date];
    return dateString;
}

+ (NSString *)display_dataStringForDate:(id)date {
    NSString *dateString = [[self display_dateFormatter] stringFromDate:date];
    return dateString;
}

+ (NSDate *)dateFromString:(NSString *)dateString{
    
    NSDateFormatter *dateFormatter = [NSDate display_dateFormatter];
    return [dateFormatter dateFromString:dateString];
}

+ (NSString *)display_onlyDateStringFromDate:(NSDate *)date{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd"];
    return [formatter stringFromDate:date];
}

+ (NSString *)display_dayOfTheWeekFromDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init] ;
    [dateFormatter setDateFormat:@"EEE"];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    return formattedDateString;
}

+ (NSString *)display_onlyTimeStringFromDate:(NSDate *)date{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    return [formatter stringFromDate:date];
}

+ (BOOL)isToday:(NSDate*)date
{
    // Split today into components
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comps = [gregorian components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit)
                                           fromDate:[NSDate date]];
    
    // Set to this morning 00:00:00
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSDate* theMidnightHour = [gregorian dateFromComponents:comps];
    
    // Get time difference (in seconds) between date and then
    NSTimeInterval diff = [date timeIntervalSinceDate:theMidnightHour];
    double kSecondsPerDay = 86400.0f;
    return (diff >= 0.0f && diff < kSecondsPerDay);
}

+ (NSString *)dateStringForEvent:(Event *)event{
    
    NSString *dateString = nil;
    if ([NSDate isToday:event.dateTime]) {
        dateString = @"Today";
    }else{
        dateString = [NSDate display_onlyDateStringFromDate:event.dateTime];
    }
    return dateString;
}


- (NSInteger)differenceInDaysToDate:(NSDate *)date {
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:self
                                                          toDate:date
                                                         options:0];
    
    return [components day];
}

#pragma mark - date of birth additions

+ (NSString *)display_dateOfBirthStringFromDate:(NSDate *)date{

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM yyyy"];
    return [formatter stringFromDate:date];
}

+ (NSString *)dateOfBirthStringFromDate:(id)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm/dd/yyyy"];
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)dateFromDateOfBirthString:(NSString *)dateOfBirthString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm/dd/yyyy"];
    return [dateFormatter dateFromString:dateOfBirthString];
}

- (NSString *)ageString {
    NSDate *today = [NSDate date];
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:self
                                       toDate:today
                                       options:0];

    NSInteger age = ageComponents.year;
    return [NSString stringWithFormat:@"%d",age];
}

@end
