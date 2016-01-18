//
//  CoreDataImporter.h
//  WBCoreData
//
//  Created by ChengYan on 15/9/29.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

// 默认数据导入引擎
// 该引擎需具备以下几个功能
/*
    1.自身需要包含一份表名和表的关键字名的字典；
    2.能够根据给定的xml字典，要插入的表，要插入的表中的关键字字段名以及xml字典中对应的关键字名来插入数据；
    3.能够根据给定的唯一标示的表名，表字段名，valuekeys字典，以及context
    4.能够保存数据
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CoreDataImporter : NSObject

@property (nonatomic, retain) NSDictionary *entitiesWithUniqueAttributes;//一份表和关键字对应的字典

+ (void)saveContext:(NSManagedObjectContext *)context;

/*!
 *  @brief  保存操作
 *
 *  @param context 要保存到的持久化存储区
 */
- (void)saveContext:(NSManagedObjectContext *)context;//使用context进行保存操作

/*!
 *  @brief  初始化
 *
 *  @param uniques 包含实体名称和实体主键的映射
 *
 *  @return importer
 */
- (id)initWithEntitiesWithUniqueAttribute:(NSDictionary *)uniques;//根据uniques进行初始化类

/*!
 *  @brief  获取实体的主键
 *
 *  @param entity 要获取主键的实体
 *
 *  @return 主键
 */
- (NSString *)uniqueAttributeWithEntity:(NSString *)entity;//获取表中的关键字子段名

/*!
 *  @brief  辅助导入数据的方法
 *
 *  @param entity          实体名称
 *  @param attributeValue  主键值
 *  @param attributeValues 实体的key&value
 *  @param context         要导入到的持久化存储区
 *
 *  @return 托管对象
 */
- (NSManagedObject *)insertUniqueObjectWithEntity:(NSString *)entity
                                   attributeValue:(NSString *)attributeValue
                                  attributeValues:(NSDictionary *)attributeValues
                                          context:(NSManagedObjectContext *)context;

/*!
 *  @brief  导入数据
 *
 *  @param entity             实体名称
 *  @param attribute          实体主键
 *  @param xmlAttribute       实体主键值
 *  @param xmlAttributeValues 导入的实体key&value
 *  @param context            要导入的持久化存储区
 *
 *  @return 托管对象
 */
- (NSManagedObject *)insertBasicObjectWithEntity:(NSString *)entity
                                 entityAttribute:(NSString *)attribute
                                    xmlAttribute:(NSString *)xmlAttribute
                              xmlAttributeValues:(NSDictionary *)xmlAttributeValues
                                         context:(NSManagedObjectContext *)context;

/*!
 *  @brief  执行深拷贝
 *
 *  @param entities           实体名称数组
 *  @param sourceContext      源持久化存储区
 *  @param destinationContext 目标持久化存储区
 */
- (void)deepCopyEntities:(NSArray *)entities
      fromSoureceContext:(NSManagedObjectContext *)sourceContext
    toDestinationContext:(NSManagedObjectContext *)destinationContext;
@end
