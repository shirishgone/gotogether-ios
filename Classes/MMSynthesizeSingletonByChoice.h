//
//  MMSynthesizeSingletonByChoice.h
//  MM Shared Ideas
//
//  Created by Robert Duke on 12/18/11.
//  Copyright 2011 Mutual Mobile. All rights reserved.
//

#define SYNTHESIZE_CONSTRUCTOR_FOR_CLASS(classname) \
+ (NSArray*)classname##sFromDict:(NSDictionary*)dict \
inContext:(NSManagedObjectContext*)ctx \
error:(NSError**)outError;

#define SYNTHESIZE_SINGLETONBYCHOICE_HEADER_FOR_CLASS(classname) \
\
+ (classname *)shared##classname;\
+ (void)setShared##classname:(classname*)serv;

#define SYNTHESIZE_SINGLETONBYCHOICE_FOR_CLASS(classname) \
\
static classname *sharedObj##classname = nil; \
+ (classname *)shared##classname \
{ \
if( sharedObj##classname == nil){\
    sharedObj##classname = [[self alloc] init];\
    }\
return sharedObj##classname;\
} \
+ (void)setShared##classname:(classname*)serv\
{\
    sharedObj##classname = serv;\
}

