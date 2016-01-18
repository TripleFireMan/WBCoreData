//
//  ItemPhoto.h
//  WBCoreData
//
//  Created by ChengYan on 15/10/14.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface ItemPhoto : NSManagedObject

@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) Item *item;

@end
