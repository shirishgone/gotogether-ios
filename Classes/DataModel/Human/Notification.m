#import "Notification.h"


@interface Notification ()

// Private interface goes here.

@end


@implementation Notification

+ (void)notificationFromUserId:(NSString *)userId
                          type:(NSString *)type
                       eventId:(NSString *)eventId
                  alertMessage:(NSString *)alertMessage
                        sucess:(void (^)(Notification* notification))handleSuccess
                       failure:(void (^)(NSError *error))handleFailure{

    Notification *notification = [Notification MR_createInContext:[NSManagedObjectContext defaultContext]];
    notification.alertMessage = alertMessage;
    notification.userId = userId;
    notification.type = type;
    notification.eventId = eventId;
    notification.readValue = NO;
    notification.date = [NSDate date];
    
    [[NSManagedObjectContext defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
    
        if (error !=nil) {
            handleFailure (error);
        }else{
            handleSuccess(notification);
        }
    }];
}

- (void)setNotificationAsRead:(BOOL)read{
    self.readValue = read;
    [[NSManagedObjectContext defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
    }];
}

+ (NSArray *)notificationsForUserId:(NSString *)userId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", userId];
    NSArray *notifications = [Notification MR_findAllWithPredicate:predicate
                                                  inContext:[NSManagedObjectContext defaultContext]];
    return notifications;
}

+ (NSArray *)allNotifications {

    return [Notification MR_findAllSortedBy:@"date"
                                  ascending:NO
                                  inContext:[NSManagedObjectContext defaultContext]];
}

+ (NSUInteger)unreadNotificationsCount {
    int count = 0;
    NSArray *notifications = [Notification allNotifications];
    for (Notification *notif in notifications) {
        if(notif.readValue == NO){
            count++;
        }
    }
    return count;
}

- (NotificationType)notificationType{
    if ([self.type  isEqual:@"book_seat"]) {
        return notificationType_bookSeat;
    }else if ([self.type  isEqual: @"edit_event"]){
        return notificationType_editEvent;
    }else if ([self.type  isEqual: @"comment"]){
        return notificationType_eventComment;
    }else if ([self.type  isEqual: @"accept_event"]){
        return notificationType_confirmSeat;
    }else if ([self.type  isEqual: @"create_event"]){
        return notificationType_createEvent;
    }else{
        return 0;
    }
}

+ (void)clearAllNotifications {
    NSManagedObjectContext *context = [NSManagedObjectContext defaultContext];
    for (Notification *notification in [Notification allNotifications]) {
        [context deleteObject:notification];
    }
    [context save:nil];
}

#pragma mark - Demo Data
+ (void)insertSampleNotifications{

    [Notification notificationFromUserId:@"shirishgone@yahoo.com"
                                    type:@"book_seat"
                                 eventId:@"12324"
                            alertMessage:@"Shirish has requested for a seat in your ride from Hyd to BlR"
                                  sucess:^(Notification *notification) {
                                      
                                  } failure:^(NSError *error) {
                                      
                                  }];

    [Notification notificationFromUserId:@"shirishgone@yahoo.com"
                                    type:@"create_event"
                                 eventId:@"12324"
                            alertMessage:@"Your Friend shirish is looking for a Ride from Warangal to Hyderabad."
                                  sucess:^(Notification *notification) {
                                      
                                  } failure:^(NSError *error) {
                                      
                                  }];
    
    [Notification notificationFromUserId:@"shirishgone@yahoo.com"
                                    type:@"edit_event"
                                 eventId:@"12324"
                            alertMessage:@"Shirish has updated the event details from Secbd to Hyd. Check it out."
                                  sucess:^(Notification *notification) {
                                      
                                  } failure:^(NSError *error) {
                                      
                                  }];

    
    [Notification notificationFromUserId:@"shirishgone@yahoo.com"
                                    type:@"comment"
                                 eventId:@"12324"
                            alertMessage:@"Shirish has commented on your ride from Hyd to Secbd."
                                  sucess:^(Notification *notification) {
                                      
                                  } failure:^(NSError *error) {
                                      
                                  }];

    
    [Notification notificationFromUserId:@"shirishgone@yahoo.com"
                                    type:@"accept_event"
                                 eventId:@"12324"
                            alertMessage:@"Your Friend shirish has accepted your Request to take you from Secbd to Hyd."
                                  sucess:^(Notification *notification) {
                                      
                                  } failure:^(NSError *error) {
                                      
                                  }];

}
@end
