#import "_Notification.h"

typedef enum {
    notificationType_bookSeat,
    notificationType_confirmSeat,
    notificationType_eventComment,
    notificationType_createEvent,
    notificationType_editEvent
} NotificationType;

@interface Notification : _Notification {}


+ (void)notificationFromUserId:(NSString *)userId
                          type:(NSString *)type
                       eventId:(NSString *)eventId
                  alertMessage:(NSString *)alertMessage
                        sucess:(void (^)(Notification* notification))handleSuccess
                       failure:(void (^)(NSError *error))handleFailure;

- (void)setNotificationAsRead:(BOOL)read;

+ (NSArray *)notificationsForUserId:(NSString *)userId;

+ (NSArray *)allNotifications;

- (NotificationType)notificationType;

+ (NSUInteger)unreadNotificationsCount;

+ (void)clearAllNotifications;

@end
