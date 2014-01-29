//
//  Cat.h
//  Transitions
//
//  Created by Haldun Bayhantopcu on 29/01/14.
//  Copyright (c) 2014 Monoid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Cat : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * catDescription;
@property (nonatomic, retain) NSNumber * age;

@end
