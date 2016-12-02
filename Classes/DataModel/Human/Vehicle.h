#import "_Vehicle.h"

@interface Vehicle : _Vehicle {}
// Custom logic goes here.
+ (Vehicle *)vehicleForVehicleNumber:(NSString *)vehicleNumber;
+ (BOOL)isVehicleDetailsAvailable;
+ (void)addVehicleWithNumber:(NSString *)vehicleNumber
                        make:(NSString *)make
                       model:(NSString *)model
                       color:(NSString *)color
                      sucess:(void (^)(id response))handleSuccess
                     failure:(void (^)(NSError *error))handleFailure;

//+ (void)saveVehicleWithNumber:(NSString *)vehicleNumber
//                         make:(NSString *)make
//                        model:(NSString *)model;

+ (void)getVehiclesWithSucess:(void (^)(NSDictionary *vehicles))handleSuccess
                      failure:(void (^)(NSError *error))handleFailure;
@end
