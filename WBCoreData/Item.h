//
//  Item.h
//  WBCoreData
//
//  Created by ChengYan on 15/10/14.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItemPhoto, LocationHome, LocationShop, Unit;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSNumber * collected;
@property (nonatomic, retain) NSNumber * listed;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) LocationHome *locationHome;
@property (nonatomic, retain) LocationShop *locationShop;
@property (nonatomic, retain) Unit *unit;
@property (nonatomic, retain) ItemPhoto *photo;

@end
