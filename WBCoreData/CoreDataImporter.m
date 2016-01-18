//
//  CoreDataImporter.m
//  WBCoreData
//
//  Created by ChengYan on 15/9/29.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import "CoreDataImporter.h"
@interface CoreDataImporter()

@end

@implementation CoreDataImporter

+ (void)saveContext:(NSManagedObjectContext *)context
{
    if ([context hasChanges]) {
        [context performBlockAndWait:^{
            NSError *error = nil;
            [context save:&error];
        }];
    }else{
        NSLog(@"nothing has changed!");
    }
}

- (id)initWithEntitiesWithUniqueAttribute:(NSDictionary *)uniques
{
    self = [super init];
    if (self) {
        self.entitiesWithUniqueAttributes = uniques;
        if (self.entitiesWithUniqueAttributes == nil) {
            
            NSLog(@"entitiesAttributes is nil!");
            return nil;
        }
    }
    return self;
}

- (void)saveContext:(NSManagedObjectContext *)context
{
    if ([context hasChanges]) {
        [context performBlockAndWait:^{
            NSError *error = nil;
            [context save:&error];
        }];
    }else{
        NSLog(@"nothing has changed!");
    }
}

- (NSString *)uniqueAttributeWithEntity:(NSString *)entity
{
    NSString *uniqueAttribute = [self.entitiesWithUniqueAttributes valueForKey:entity];
    return uniqueAttribute;
}

- (NSManagedObject *)existingObjextInContext:(NSManagedObjectContext *)context
                         entity:(NSString *)entity
                 attributeValue:(NSString *)attributeValue
{
    NSString *uniqueAttribute = [self uniqueAttributeWithEntity:entity];

    NSFetchRequest *request   = [NSFetchRequest fetchRequestWithEntityName:entity];
    NSPredicate *predicate    = [NSPredicate predicateWithFormat:@"%K == %@",uniqueAttribute,attributeValue];
    [request setFetchLimit:1];
    [request setPredicate:predicate];
    NSArray *result           = [context executeFetchRequest:request error:nil];
    if (result == 0) {
        return nil;
    }else{
        return result.lastObject;
    }
}

- (NSManagedObject *)insertUniqueObjectWithEntity:(NSString *)entity
                                   attributeValue:(NSString *)attributeValue
                                  attributeValues:(NSDictionary *)attributeValues
                                          context:(NSManagedObjectContext *)context
{
    NSString *uniqueAttribute = [self uniqueAttributeWithEntity:entity];
    if (uniqueAttribute.length != 0) {
        NSManagedObject *object = [self existingObjextInContext:context entity:entity attributeValue:attributeValue];
        if (object != nil) {
            return object;
        }else {
            NSManagedObject *newobject = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:context];
            [newobject setValuesForKeysWithDictionary:attributeValues];
            return newobject;
        }
    }else {
        NSLog(@"uniqueAttribute is nil");
        return nil;
    }
}

- (NSManagedObject *)insertBasicObjectWithEntity:(NSString *)entity
                                 entityAttribute:(NSString *)attribute
                                    xmlAttribute:(NSString *)xmlAttribute
                              xmlAttributeValues:(NSDictionary *)xmlAttributeValues
                                         context:(NSManagedObjectContext *)context
{
    NSArray *arrayForEntityAttribute           = [NSArray arrayWithObject:attribute];
    NSArray *arrayForEntityAttributeValue      = [NSArray arrayWithObject:[xmlAttributeValues objectForKey:xmlAttribute]];
    NSDictionary *dictionaryForAttributeValues = [NSDictionary dictionaryWithObjects:arrayForEntityAttributeValue forKeys:arrayForEntityAttribute];
    NSManagedObject *managedObject             = [self insertUniqueObjectWithEntity:entity attributeValue:[xmlAttributeValues valueForKey:xmlAttribute] attributeValues:dictionaryForAttributeValues context:context];
    return managedObject;
}

#pragma mark - DEEP COPY

- (NSString *)objectInfo:(NSManagedObject *)object
{
    NSString *uniqueAttribute      = [self uniqueAttributeWithEntity:[object entity].name];
    NSString *uniqueAttributeValue = [object valueForKey:uniqueAttribute];
    return [NSString stringWithFormat:@"entity : %@, value : %@",[object entity],uniqueAttributeValue];
}

//拷贝数据
- (NSManagedObject *)copyUniqueObject:(NSManagedObject *)object
                            toContext:(NSManagedObjectContext *)targetContext
{
    if (!object || !targetContext) {
        return nil;
    }
    
    NSString *entity               = [[object entity]name];
    NSString *uniqueAttribute      = [self uniqueAttributeWithEntity:entity];
    NSString *uniqueAttributeValue = [object valueForKey:uniqueAttribute];
    
    if (uniqueAttribute.length > 0) {
        NSMutableDictionary *attributeValuesToCopy = [NSMutableDictionary new];
        
        NSLog(@"object.entity.attributesByName : %@",object.entity.attributesByName);
        
        for (NSString *attribute in object.entity.attributesByName) {
            [attributeValuesToCopy setValue:[[object valueForKey:attribute]copy] forKey:attribute];
        }
        
        NSManagedObject *managerObject = [self insertUniqueObjectWithEntity:entity
                                                             attributeValue:uniqueAttributeValue
                                                            attributeValues:attributeValuesToCopy
                                                                    context:targetContext];
        return managerObject;
        
    }else {
        return nil;
    }
}

- (void)copyRelationShipsFromObject:(NSManagedObject *)object
                          toContext:(NSManagedObjectContext *)context
{
    //关系拷贝 要区分是一对一、一对多、还是有序的一对多关系
    
    //校验数据合法性，如不合法 不执行后续操作
    if (!object || !context) {
        NSLog(@"failed copy relationships, %@",[self objectInfo:object]);
        return;
    }
    
    //继续校验目标上下文上是否存在源对象的copy，如果不存在，不执行后续操作
    NSManagedObject *copyedObject = [self copyUniqueObject:object toContext:context];
    if (!copyedObject) {
        NSLog(@"nil copyedobject is illegal!");
        return;
    }
    
    //然后获取关系列表
    NSDictionary *relationShips = [[object entity]relationshipsByName];
    
    for (NSString *relationShipName in relationShips) {
        NSRelationshipDescription *relationShip = [relationShips valueForKey:relationShipName];
        
        //如果源数据有关系，没有关系自然直接跳过
        if ([object valueForKey:relationShipName]) {
            if (relationShip.isToMany && relationShip.isOrdered) {
                //执行一对多且有序的关系重建
                
                NSMutableOrderedSet *relatedOrderdSet = [object mutableOrderedSetValueForKey:relationShipName];
                [self establishOrderedToManyRelationShip:relationShipName fromObject:copyedObject set:relatedOrderdSet];
            }else if (relationShip.isToMany && !relationShip.isOrdered){
                //执行一对多且无序的关系重建

                NSMutableSet *relatedSet = [object mutableSetValueForKey:relationShipName];
                [self establishToManyRelationShip:relationShipName fromObject:copyedObject set:relatedSet];
            }else {
                //执行一对一关系重建
                
                NSManagedObject *sourceShipObject         = [object valueForKey:relationShipName];
                NSManagedObject *copyedRelationShipObject = [self copyUniqueObject:sourceShipObject toContext:context];
                [self establishToOneRelationShip:relationShipName fromObject:copyedObject toObject:copyedRelationShipObject];
            }
        }
    }
}

- (void)establishOrderedToManyRelationShip:(NSString *)relationShipName fromObject:(NSManagedObject *)object set:(NSMutableOrderedSet *)orderedSet
{
    if (!relationShipName || !object || !orderedSet) {
        NSLog(@"SKIPED establish ordered to-many relationship from %@",[self objectInfo:object]);
        NSLog(@"Due to Missing info");
        return;
    }
    
    NSMutableOrderedSet *relationShipOrderSet = [object mutableOrderedSetValueForKey:relationShipName];
    NSLog(@"Begin MutableOrderset relationship establish");
    
    for (NSManagedObject *sourceObject in orderedSet) {
        NSManagedObject *copyedRelatedObject = [self copyUniqueObject:sourceObject toContext:object.managedObjectContext];
        if (copyedRelatedObject) {
            [relationShipOrderSet addObject:copyedRelatedObject];
        }
    }
    
    [self saveContext:object.managedObjectContext];
    [object.managedObjectContext refreshObject:object mergeChanges:NO];
}

- (void)establishToManyRelationShip:(NSString *)relationShipName fromObject:(NSManagedObject *)object set:(NSMutableSet *)set
{
    if (!relationShipName || !object ||!set) {
        
        NSLog(@"SKIPED establish to-many relationship from %@",[self objectInfo:object]);
        NSLog(@"Due to missing info");
        return;
    }
    
    //如何重建一对多的无序关系？
    /*
     1.查询该托管对象是否已经重建过一对多关系，如果有，不再进行关系重建.
     2.如果没有，那么就进行关系的重建
     3.根据源托管对象关系集，获取单个关系托管对象，并将他们复制到目标托管区
     4.然后获取托管对象的关系集合，将新关系添加进去。
     5.别忘记保存，另外将托管对象从context中移除
     */
    
    NSMutableSet *relationManagerObjects = [object mutableSetValueForKey:relationShipName];
    NSLog(@"Begin establish to-many relationship! relationSets; %@",relationManagerObjects);
    
    for (NSManagedObject *sourceObj in set) {
        NSManagedObject *copyedSourceObj = [self copyUniqueObject:sourceObj toContext:object.managedObjectContext];
        if (copyedSourceObj) {
            [relationManagerObjects addObject:copyedSourceObj];
            NSLog(@"A copy of %@ now related via To-Many %@ relationship to %@",[self objectInfo:object],relationShipName,[self objectInfo:copyedSourceObj]);
        }
    }
    [self saveContext:object.managedObjectContext];
    [object.managedObjectContext refreshObject:object mergeChanges:NO];
}

- (void)establishToOneRelationShip:(NSString *)relationShipName fromObject:(NSManagedObject *)from toObject:(NSManagedObject *)to
{
    if (!relationShipName || !from || !to) {
        NSLog(@"SKIPED establish to-one relationship '%@' between %@ and %@",relationShipName,[self objectInfo:from],[self objectInfo:to]);
        NSLog(@"Due to Missing info");
        return;
    }
    
    NSManagedObject *relationshipObject = [from valueForKey:relationShipName];
    if (relationshipObject) {
        NSLog(@"Do not establish exist relationship");
        return;
    }
    
    NSDictionary *relationShipNames = [[from entity]relationshipsByName];
    NSRelationshipDescription *relationShip = [relationShipNames valueForKey:relationShipName];
    if (![to.entity isEqual:relationShip.destinationEntity]) {
        NSLog(@"%@ is the wrong entity type to relate to %@",[self objectInfo:from],[self objectInfo:to]);
        return;
    }
    
    [from setValue:to forKey:relationShipName];
    NSLog(@"establish %@ relationship from %@ to %@",relationShipName,[self objectInfo:from],[self objectInfo:to]);
    
    [self saveContext:from.managedObjectContext];
    [self saveContext:to.managedObjectContext];
    
    [from.managedObjectContext refreshObject:from mergeChanges:NO];
    [to.managedObjectContext refreshObject:to mergeChanges:NO];
    
}

- (NSArray *)arrayFromEntity:(NSString *)entity
                     context:(NSManagedObjectContext *)context
                   predicate:(NSPredicate *)predicate
{
    if (!entity || !context) {
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setFetchBatchSize:10];
    NSArray *result = [context executeFetchRequest:fetchRequest error:nil];
    NSLog(@"source context result = %@",result);
    return result;
}

- (void)deepCopyEntities:(NSArray *)entities
      fromSoureceContext:(NSManagedObjectContext *)sourceContext
    toDestinationContext:(NSManagedObjectContext *)destinationContext
{
    NSLog(@"deep copy entities : %@",entities);
    
    //1.需要查询源持久化存储区的对象,此处需要写一个辅助方法，根据实体名称和托管对象上下文以及谓词来获取对象数组
    
    for (NSString *entityName in entities) {
        NSArray *sourceObjects = [self arrayFromEntity:entityName
                                               context:sourceContext
                                             predicate:nil];

        //2.拿到持久化存储区中的源数据之后，需要进行的就是复制数据到目标存储区了，这里也写一个方法，执行复制操作
        //3.此外要进行的就是最为关键的关系拷贝了
        
        for (NSManagedObject *sourceObject in sourceObjects) {
            if (sourceObject) {
                @autoreleasepool {
                    [self copyUniqueObject:sourceObject toContext:destinationContext];
                    [self copyRelationShipsFromObject:sourceObject toContext:destinationContext];
                }
            }
        }
    }
}
@end
