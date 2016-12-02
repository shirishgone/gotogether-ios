#import "Vehicle.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "MMHTTPClient.h"

@interface Vehicle ()

// Private interface goes here.

@end


@implementation Vehicle

+ (Vehicle *)vehicleForVehicleNumber:(NSString *)vehicleNumber{
    
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.vehicleNumber = %@",vehicleNumber];
    Vehicle *vehicle = [Vehicle MR_findFirstWithPredicate:predicate inContext:defaultContext];
    return vehicle;

}
// Custom logic goes here.
+ (BOOL)isVehicleDetailsAvailable{
    BOOL isAvailable = NO;
    User *currentUser = [User currentUser];
    if (currentUser.vehicle != nil) {
        isAvailable = YES;
    }
    return isAvailable;
}


+ (void)addVehicleWithNumber:(NSString *)vehicleNumber
                        make:(NSString *)make
                       model:(NSString *)model
                       color:(NSString *)color
                      sucess:(void (^)(id response))handleSuccess
                     failure:(void (^)(NSError *error))handleFailure{
    
    NSString *userId = [User getUserId];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    User *user = [User currentUser];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (user.userId != nil) {
        [parameters setObject:userId forKey:@"userid"];
    }
    if (user.accessToken != nil) {
        [parameters setObject:user.accessToken forKey:@"access_token"];
    }
    if (vehicleNumber != nil) {
        [parameters setObject:vehicleNumber forKey:@"vehicle_number"];
    }
    if (make != nil) {
        [parameters setObject:make forKey:@"make"];
    }
    if (model != nil) {
        [parameters setObject:model forKey:@"model"];
    }
    if (color !=nil) {
        [parameters setObject:color forKey:@"color"];
    }
    
    NSURLRequest *request = [httpClient requestWithMethod:@"POST"
                                                     path:[NSString stringWithFormat:@"%@",kRedHotApi_addVehicle]
                                               parameters:parameters];
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSError *jsonError = nil;
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             id error = [jsonDictionary valueForKey:@"error"];
             
             if ([MMHTTPClient isError:error]) {
                 handleFailure(error);
                 return;
             }
             
             [Vehicle
              saveVehicleWithNumber:vehicleNumber
              make:make
              model:model
              sucess:^(id response) {
                  
                  NSString *successMessage = @"Vehicle added successfully";
                  handleSuccess(successMessage);
                  return;
                  
              } failure:^(NSError *error) {
                  handleFailure(error);
              }];
             
         }else{
             
             NSString *errorDescription = @"JSON is not a dictionary";
             NSInteger errorCode = 2000;
             NSString *domain = @"GoTogetherClient";
             
             jsonError = [NSError errorWithDomain:domain
                                             code:errorCode
                                         userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:@"errorDescription"]];
             handleFailure(jsonError);
             return;
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];
}

+ (void)saveVehicleWithNumber:(NSString *)vehicleNumber
                         make:(NSString *)make
                        model:(NSString *)model
                       sucess:(void (^)(id response))handleSuccess
                      failure:(void (^)(NSError *error))handleFailure{

    if (make != nil && [make length] > 0) {
        User *currentUser = [User currentUser];
        Vehicle *vehicle = [Vehicle MR_createInContext:[NSManagedObjectContext defaultContext]];
        [vehicle setVehicleNumber:vehicleNumber];
        [vehicle setMake:make];
        [vehicle setModel:model];
        currentUser.vehicle = vehicle;
    }
    
    [[NSManagedObjectContext MR_context] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        
        if (error !=nil) {
            handleFailure (error);
        }else{
            handleSuccess(@"saved successfully");
        }
    }];

}

+ (void)getVehiclesWithSucess:(void (^)(NSDictionary *vehicles))handleSuccess
                      failure:(void (^)(NSError *error))handleFailure {
    NSString *userId = [User getUserId];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[MMHTTPClient baseURL]];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    User *user = [User currentUser];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (user.userId != nil) {
        [parameters setObject:userId forKey:@"userid"];
    }
    if (user.accessToken != nil) {
        [parameters setObject:user.accessToken forKey:@"access_token"];
    }
    
    NSURLRequest *request =
    [httpClient requestWithMethod:@"POST"
                             path:[NSString stringWithFormat:@"%@",kRedHotApi_getVehicles]
                       parameters:parameters];
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSError *jsonError = nil;
         
         if ([JSON isKindOfClass:[NSDictionary class]]) {
             NSDictionary *jsonDictionary = (NSDictionary *)JSON;
             id error = [jsonDictionary valueForKey:@"error"];
             
             if ([MMHTTPClient isError:error]) {
                 handleFailure(error);
                 return;
             }
             id result = [[jsonDictionary valueForKey:@"result"] valueForKey:@"data"];
             handleSuccess(result);
             
         }else{
             
             NSString *errorDescription = @"JSON is not a dictionary";
             NSInteger errorCode = 2000;
             NSString *domain = @"GoTogetherClient";
             
             jsonError = [NSError errorWithDomain:domain
                                             code:errorCode
                                         userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:@"errorDescription"]];
             handleFailure(jsonError);
             return;
         }
     }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         handleFailure(error);
     }];
    [operation start];

}


@end
