//
//  WBCoreDataManager.h
//  WBCoreData
//
//  Created by ChengYan on 15/8/4.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ViewController.h"

extern NSString *const someThingChangedNotification;

@interface CoreDataHelper : NSObject<UIAlertViewDelegate,NSXMLParserDelegate>
{
    NSTimer *_importTimer;
}
#pragma mark - BASIC_METHOD

@property (nonatomic, strong) NSManagedObjectContext       *context;//托管对象上下文
@property (nonatomic, strong) NSManagedObjectModel         *model;//托管对象模型
@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinate;//持久化存储协调器
@property (nonatomic, strong) NSPersistentStore            *store;//持久化存储区
@property (nonatomic, retain) ViewController               *migrationVC;//迁移管理器

#pragma mark - IMPORT_DEFAULT_DATA

@property (nonatomic, retain) UIAlertView                  *importAlertView;//默认数据导入提示
@property (nonatomic, retain) NSManagedObjectContext       *importContext;//导入默认数据专用context
@property (nonatomic, retain) NSXMLParser                  *parser;//xml数据结构解析器

#pragma mark - SOURCE STORE
@property (nonatomic, strong) NSManagedObjectContext       *sourceContext;//源数据托管上下文
@property (nonatomic, strong) NSPersistentStoreCoordinator *sourceCoordinate;//源数据持久化存储协调器
@property (nonatomic, retain) NSPersistentStore            *sourceStore;//源数据持久化存储区

- (id)init;             //初始化

- (void)loadStore;      //加载coredate

- (void)setupCoreData;  //设置coredate相关信息

- (void)saveContext;    //保存context

- (void)showValidationError:(NSError *)anError; //展示数据验证错误
@end
