//
//  LocationShop.h
//  WBCoreData
//
//  Created by ChengYan on 15/10/14.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Location.h"

@class Item;

@interface LocationShop : Location

@property (nonatomic, retain) NSString * locationAtShop;
@property (nonatomic, retain) NSSet *itens;
@end

@interface LocationShop (CoreDataGeneratedAccessors)

- (void)addItensObject:(Item *)value;
- (void)removeItensObject:(Item *)value;
- (void)addItens:(NSSet *)values;
- (void)removeItens:(NSSet *)values;

@end
