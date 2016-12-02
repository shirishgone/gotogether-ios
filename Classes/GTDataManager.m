//
//  GTDataManager.m
//  goTogether
//
//  Created by shirish on 25/11/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTDataManager.h"

static GTDataManager *sharedInstance = nil;

@implementation GTDataManager

+(GTDataManager*)sharedInstance
{
    @synchronized([GTDataManager class])
    {
        if (!sharedInstance){
            sharedInstance = [[self alloc] init];
        }
        return sharedInstance;
    }
    return nil;
}

- (NSString *)shareMessage {
    return @"Hey! checkout this new app. gotogether - Intercity ride-sharing app. http://www.gotogether.mobi";
}

#pragma mark - cleanup database
- (void)cleanupDatabase {
    [User resetUserDefaults];

    [self deleteAllObjectsInContext:[NSManagedObjectContext defaultContext]
                         usingModel:[NSManagedObjectModel defaultManagedObjectModel]];
}

- (void)deleteAllObjectsInContext:(NSManagedObjectContext *)context
                       usingModel:(NSManagedObjectModel *)model {
    NSArray *entities = model.entities;
    for (NSEntityDescription *entityDescription in entities) {
        [self deleteAllObjectsWithEntityName:entityDescription.name
                                   inContext:context];
    }
    [context saveToPersistentStoreWithCompletion:nil];
}

- (void)deleteAllObjectsWithEntityName:(NSString *)entityName
                             inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest =
    [NSFetchRequest fetchRequestWithEntityName:entityName];
    fetchRequest.includesPropertyValues = NO;
    fetchRequest.includesSubentities = NO;
    
    NSError *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
        TALog(@"Deleted %@", entityName);
    }
}


@end
