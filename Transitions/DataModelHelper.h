//
//  DataModelHelper.h
//  Transitions
//
//  Created by Haldun Bayhantopcu on 29/01/14.
//  Copyright (c) 2014 Monoid. All rights reserved.
//

@import Foundation;
@import CoreData;

@interface DataModelHelper : NSObject

@property (strong, readonly, nonatomic) NSManagedObjectContext *mainObjectContext;
@property (strong, readonly, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (instancetype)sharedHelper;

@end
