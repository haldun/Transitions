//
//  DataModelHelper.m
//  Transitions
//
//  Created by Haldun Bayhantopcu on 29/01/14.
//  Copyright (c) 2014 Monoid. All rights reserved.
//

#import "DataModelHelper.h"

@interface DataModelHelper ()

@property (strong, readwrite, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, readwrite, nonatomic) NSManagedObjectContext *mainObjectContext;

@end

@implementation DataModelHelper

+ (instancetype)sharedHelper
{
  static DataModelHelper *_sharedHelper = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedHelper = [[DataModelHelper alloc] init];
  });
  return _sharedHelper;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    [self setup];
  }
  return self;
}

- (void)setup
{
  // setup object model
  NSString *pathToModel = [[NSBundle mainBundle] pathForResource:@"Transitions" ofType:@"momd"];
  NSURL *storeURL = [NSURL fileURLWithPath:pathToModel];
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:storeURL];
  
  // setup peristent coordinator
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
  NSString *dbFilename = @"db.sqlite3";
  NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
  NSURL *dbURL = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingString:dbFilename]];
  
  // store coordinate options
  NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                            NSInferMappingModelAutomaticallyOption: @YES};
  
  NSError *error = nil;
  if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                 configuration:nil
                                                           URL:dbURL
                                                       options:options
                                                         error:&error]) {
    NSLog(@"Cannot initialize store: %@", error);
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Could not create persistent store"
                                 userInfo:error.userInfo];
  }
}

- (NSManagedObjectContext *)mainObjectContext
{
  if (!_mainObjectContext) {
    _mainObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _mainObjectContext.persistentStoreCoordinator = _persistentStoreCoordinator;
  }
  return _mainObjectContext;
}

@end
