//
//  LocationHome.h
//  WBCoreData
//
//  Created by ChengYan on 15/10/14.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Location.h"

@class Item;

@interface LocationHome : Location

@property (nonatomic, retain) NSString * locationAtHome;
@property (nonatomic, retain) NSSet *items;
@end

@interface LocationHome (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
