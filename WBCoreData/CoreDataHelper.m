//
//  WBCoreDataManager.m
//  WBCoreData
//
//  Created by ChengYan on 15/8/4.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import "CoreDataHelper.h"

#import "CoreDataImporter.h"

NSString *const someThingChangedNotification = @"someThingChangedNotification";

#define debug                   1                       //是否开启log模式
#define MigrationMode           1                       //是否开启迁移模式
#define DEFAULT_DATA_IMPORT_KEY @"defaultDataIsImported"//是否已经导入默认数据

#pragma mark - FILES

static NSString *storeFileName = @"demo.sqlite";    //测试数据库

@implementation CoreDataHelper

#pragma mark - PATHS

- (NSString *)applicationDocumentDirectory
{
    if (debug) {
        NSLog(@"Running %@ '%@'",[self class],NSStringFromSelector(_cmd));
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}

- (NSURL *)applicationStoreDirectory
{
    if (debug) {
        NSLog(@"Running %@ '%@'",[self class],NSStringFromSelector(_cmd));
    }
    
    NSURL *url = [[NSURL fileURLWithPath:[self applicationDocumentDirectory]] URLByAppendingPathComponent:@"stores"];
    if (![[NSFileManager defaultManager]fileExistsAtPath:[url path]]) {
        NSError *error = nil;
        BOOL success   = [[NSFileManager defaultManager]createDirectoryAtURL:url
                                               withIntermediateDirectories:YES
                                                                attributes:nil
                                                                     error:&error];
        if (success) {
            if (debug) {
                NSLog(@"success create directory!");
            }
        }else{
            NSLog(@"failed create directory!");
        }
    }
    
    return url;
}

- (NSURL *)storeUrl
{
    NSURL *storeUrl = [[self applicationStoreDirectory]URLByAppendingPathComponent:storeFileName];
    NSLog(@"storeurl = %@",storeUrl);
    return storeUrl;
}

- (NSURL *)sourceStoreUrl
{
    NSURL *sourceUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"demo" ofType:@"sqlite"]];
    return sourceUrl;
}

#pragma mark - SETUP
- (id)init
{
    if (self) {
        _model      = [NSManagedObjectModel mergedModelFromBundles:nil];
        _coordinate = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:_model];
        _context    = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [_context setPersistentStoreCoordinator:_coordinate];
        
        _importContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        
        [_importContext performBlock:^{
            [_importContext setPersistentStoreCoordinator:_coordinate];
            [_importContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            [_importContext setUndoManager:nil];
        }];
        
        //配置源数据coredata栈
        _sourceCoordinate = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:_model];//深拷贝必须使用相同的model
        _sourceContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_sourceContext performBlock:^{
            [_sourceContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
            [_sourceContext setPersistentStoreCoordinator:_sourceCoordinate];
            [_sourceContext setUndoManager:nil];
        }];
    }
    return self;
}

- (void)loadStore
{
    if (debug) {
        NSLog(@"Running %@ ,'%@'",[self class], NSStringFromSelector(_cmd));
    }
    
    if (_store) {
        return;
    }
  
    BOOL useMigrateManager = MigrationMode;

    if (useMigrateManager && [self isMigrationNecessaryForStore:[self storeUrl]]) {
        [self performBackgroundManagedMigrationForStore:[self storeUrl]];
    }else{
        NSError *error;
        
        //NSMigratePersistentStoresAutomaticallyOption coreData尝试将低版本的数据模型向高版本进行迁移
        //NSInferMappingModelAutomaticallyOption    coredata会自动创建迁移模型，会去自动尝试
        NSDictionary *option = @{NSMigratePersistentStoresAutomaticallyOption:@(YES),
                                 NSInferMappingModelAutomaticallyOption:@(YES),
                                 NSSQLitePragmasOption:@{@"journal_mode":@"DELETE"}};
        
        _store = [_coordinate addPersistentStoreWithType:NSSQLiteStoreType
                                           configuration:nil
                                                     URL:[self storeUrl]
                                                 options:option
                                                   error:&error];
        if (!_store) {
            if (debug) {
                NSLog(@"failed load store,error = %@",error);
                abort();
            }
        }
        else/**/{
            NSLog(@"successfully add store : %@",_store);
        }
    }
}

- (void)loadSourceStore
{
    if (_sourceStore) {
        return;
    }
    
    NSError *error        = nil;
    NSDictionary *options = @{NSReadOnlyPersistentStoreOption:@YES};
    _sourceStore          = [_sourceCoordinate addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:[self sourceStoreUrl]
                                                         options:options
                                                           error:&error];
    if (!_sourceStore) {
        NSLog(@"failed load store");
        abort();
    }else {
        NSLog(@"success loaded source store");
    }
}

- (void)setupCoreData
{
    if (debug) {
        NSLog(@"Runing %@ '%@'",[self class],NSStringFromSelector(_cmd));
    }
//    [self setDefaultDataStoreAsInitialStore];
    [self loadStore];
//    [self checkIsImportedDefaultData];
    [self importTestGeoceryData];
}

- (void)saveContext
{
    if (debug) {
        NSLog(@"Running %@ '%@'",[self class],NSStringFromSelector(_cmd));
    }
    
    if ([_context hasChanges]) {
        NSError *error = nil;
        if ([_context save:&error]) {
            NSLog(@"context save successfully");
        }else{
            NSLog(@"failed save %@",error);
        }
    }else{
        NSLog(@"skipped context save , there is no changes");
    }
}

#pragma mark - MIGRATION MANAGER

- (BOOL)isMigrationNecessaryForStore:(NSURL *)storeUrl
{
    if (debug) {
        NSLog(@"Running %@ '%@'",[self class],NSStringFromSelector(_cmd));
    }
    
    //文件是否存在，如果不存在认为是用户设备上并没有持久化存储区，自然不需要迁移
    if (![[NSFileManager defaultManager]fileExistsAtPath:[self storeUrl].path isDirectory:nil]) {
        if (debug) {
            NSLog(@"Skipped Migration, source database missing");
        }
        return NO;
    }
    
    NSError *error                         = nil;
    NSDictionary *sourceMetaData           = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                                        URL:storeUrl
                                                                                                      error:&error];

    NSManagedObjectModel *destinationModel = _coordinate.managedObjectModel;
    
    //比较当前对象模型是否与用户之前安装的应用持久化存储区是否兼容。如果兼容，不需要迁移
    if ([destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetaData]) {
        if (debug) {
            NSLog(@"Skipped Migration, source database is already compatible");
            return NO;
        }
    }
     
    //所有情况都尝试了，发现还是需要进行数据迁移
    return YES;
}

- (BOOL)migrateStore:(NSURL *)store
{
    if (debug) {
        NSLog(@"Running %@ '%@'",[self class],NSStringFromSelector(_cmd));
    }
    
    
    NSDictionary *sourceMeta               = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                                        URL:store
                                                                                                      error:nil];

    NSManagedObjectModel *sourceModel      = [NSManagedObjectModel mergedModelFromBundles:nil
                                                                         forStoreMetadata:sourceMeta];

    NSManagedObjectModel *destinationModel = _model;
    NSMappingModel *mappingModel           = [NSMappingModel mappingModelFromBundles:nil
                                                                      forSourceModel:sourceModel
                                                                    destinationModel:destinationModel];
    if (mappingModel) {
        NSError *error                       = nil;

        NSMigrationManager *migrationManager = [[NSMigrationManager alloc]initWithSourceModel:sourceModel
                                                                             destinationModel:destinationModel];

        [migrationManager addObserver:self
                           forKeyPath:@"migrationProgress"
                              options:NSKeyValueObservingOptionNew
                              context:nil];

        NSURL *destinationStore              = [[self applicationStoreDirectory]URLByAppendingPathComponent:@"temp.sqlite"];
        BOOL success                         = NO;
        success                              = [migrationManager migrateStoreFromURL:store
                                                    type:NSSQLiteStoreType
                                                 options:nil
                                        withMappingModel:mappingModel
                                        toDestinationURL:destinationStore
                                         destinationType:NSSQLiteStoreType
                                      destinationOptions:nil
                                                   error:&error];
        if (success) {
            if (debug) {
                NSLog(@"Migration Successfully!");
            }
            if ([self replaceStore:store withStore:destinationStore]) {
                [migrationManager removeObserver:self forKeyPath:@"migrationProgress" context:NULL];
                [[NSNotificationCenter defaultCenter]postNotificationName:someThingChangedNotification object:nil];
            }
        }else{
            if (debug) {
                NSLog(@"Migration Failed");
            }
        }
    }else{
        if (debug) {
            NSLog(@"Mapping model is NULL");
        }
    }
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"migrationProgress"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float progress                         = [[change objectForKey:NSKeyValueChangeNewKey]floatValue];
            self.migrationVC.progressView.progress = progress;

            int percenttage                        = progress * 100;
            NSString *string                       = [NSString stringWithFormat:@"Migration Progress %i%%",percenttage];
            self.migrationVC.progressLabel.text    = string;
        });
    }
}

- (BOOL)replaceStore:(NSURL *)old withStore:(NSURL *)new
{
    BOOL success   = NO;
    NSError *error = nil;
    if ([[NSFileManager defaultManager]removeItemAtURL:old error:&error]) {
        error = nil;
        if ([[NSFileManager defaultManager]moveItemAtURL:new toURL:old error:&error]) {
            success = YES;
        }else {
            if (debug) {
                NSLog(@"failed move new store to old");
            }
        }
    }else{
        if (debug) {
            NSLog(@"failed remove old store");
        }
    }
    return success;
}

- (void)performBackgroundManagedMigrationForStore:(NSURL *)store
{
    if (debug) {
        NSLog(@"Running %@ '%@'",[self class],NSStringFromSelector(_cmd));
    }
    
    UIStoryboard *sb                      = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.migrationVC                      = [sb instantiateViewControllerWithIdentifier:@"migration"];

    UIApplication *app                    = [UIApplication sharedApplication];
    UINavigationController *navigationCtl = (UINavigationController *)[app keyWindow].rootViewController;
    
    [navigationCtl presentViewController:self.migrationVC
                                animated:YES
                              completion:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
       
        BOOL done = [self migrateStore:[self storeUrl]];
        if (done) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error              = nil;

                NSDictionary *configuration = @{NSMigratePersistentStoresAutomaticallyOption:@(YES),
                                                NSInferMappingModelAutomaticallyOption:@(YES),
                                                NSSQLitePragmasOption:@{@"journal_mode":@"DELETE"}};

                _store                      = [_coordinate addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:[self storeUrl]
                                                         options:configuration
                                                           error:&error];
                if (_store) {
                    if (debug) {
                        NSLog(@"success create store");
                    }
                }else {
                    if (debug) {
                        NSLog(@"failed, error = %@",error);
                    }
                    abort();
                }
                
                [self.migrationVC dismissViewControllerAnimated:YES
                                                     completion:nil];
                
                self.migrationVC = nil;
            });
        }
        
    });
}

#pragma mark - IMPORTER DEFAULT DATA

- (BOOL)isDefaultDataIsImportFromStoreUrl:(NSURL *)storeUrl ofType:(NSString *)type
{
    NSError *error         = nil;
    NSDictionary *meteData = [NSPersistentStoreCoordinator
                              metadataForPersistentStoreOfType:type
                              URL:storeUrl error:&error];
    if (error) {
        NSLog(@"metadata find error %@",error.localizedDescription);
    }
    
    if (![[meteData valueForKey:DEFAULT_DATA_IMPORT_KEY]boolValue]) {
        
        NSLog(@"default data has not imported!");
        return NO;
    }
    
    return YES;//默认是已经导入成功
}

- (void)checkIsImportedDefaultData
{
    NSURL *storeUrl = [self storeUrl];
    if (![self isDefaultDataIsImportFromStoreUrl:storeUrl ofType:NSSQLiteStoreType]) {
        self.importAlertView = [[UIAlertView alloc]initWithTitle:@"提示"
                                                         message:@"系统检测到您的设备还没有导入默认数据，是否需要导入默认数据？"
                                                        delegate:self
                                               cancelButtonTitle:@"不导入"
                                               otherButtonTitles:@"导入", nil];
        [self.importAlertView show];
    }
}

- (void)setDefaultDataAsImportFormStore:(NSPersistentStore *)store
{
    NSMutableDictionary *metadata = [NSMutableDictionary dictionaryWithDictionary:[[store metadata] copy]];

    [metadata setObject:@YES forKey:DEFAULT_DATA_IMPORT_KEY];
    [NSPersistentStoreCoordinator setMetadata:metadata forPersistentStoreOfType:NSSQLiteStoreType URL:[self storeUrl] error:nil];
}

- (void)importFromXML:(NSString *)xmlPath
{
    self.parser = [[NSXMLParser alloc]initWithContentsOfURL:[NSURL fileURLWithPath:xmlPath]];
    self.parser.delegate = self;
    [self.parser parse];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:someThingChangedNotification object:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.importAlertView) {
        
        if (buttonIndex == alertView.cancelButtonIndex) {
            NSLog(@"user cancel import defaultdata!");
        }else if (buttonIndex == alertView.firstOtherButtonIndex){
//            NSURL *xmlPath = [[NSBundle mainBundle]URLForResource:@"DefaultData" withExtension:@"xml"];
            
            /*
             NSString *xmlPath = [[NSBundle mainBundle]pathForResource:@"DefaultData" ofType:@"xml"];
             [_importContext  performBlock:^{
             [self importFromXML:xmlPath];
             }];
             */
            
            //此处使用将持久化存储区当作用户之前已经有的存储区来进行数据迁移
            [self loadSourceStore];//加载源持久化存储区
            [self deepCopyFromPersistentStore:[self sourceStoreUrl]];
        }
        [self setDefaultDataAsImportFormStore:_store];
    }
    
    
}

//将默认数据从默认的sqlite中导入到沙盒中
- (void)setDefaultDataStoreAsInitialStore
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExistsAtStoreUrl = [fileManager fileExistsAtPath:[self storeUrl].path];
    if (!fileExistsAtStoreUrl) {
        NSURL *fileUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"demo" ofType:@"sqlite"]];
        //如果没有文件，那么就从bundle中导入
        NSError *error = nil;
        if (![fileManager copyItemAtPath:fileUrl.path toPath:[self storeUrl].path error:&error]) {
            NSLog(@"copy failed");
        }else{
            NSLog(@"copy success");
            [[NSNotificationCenter defaultCenter]postNotificationName:someThingChangedNotification object:nil];
        }
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"error = %@",parseError);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    [_importContext performBlockAndWait:^{
        if ([elementName isEqualToString:@"item"]) {
            NSLog(@"attributeDict = %@",attributeDict);

            CoreDataImporter *importer      = [[CoreDataImporter alloc]initWithEntitiesWithUniqueAttribute:[self selectedUniqueAttributes]];
            NSManagedObject *item           = [importer insertBasicObjectWithEntity:@"Item"
                                                           entityAttribute:@"name"
                                                              xmlAttribute:@"name"
                                                        xmlAttributeValues:attributeDict
                                                                   context:_importContext];

            NSManagedObject *unit           = [importer insertBasicObjectWithEntity:@"Unit"
                                                          entityAttribute:@"name"
                                                             xmlAttribute:@"unit"
                                                       xmlAttributeValues:attributeDict
                                                                  context:_importContext];

            NSManagedObject *locationAtHome = [importer insertBasicObjectWithEntity:@"LocationHome"
                                                                    entityAttribute:@"locationAtHome"
                                                                       xmlAttribute:@"locationathome"
                                                                 xmlAttributeValues:attributeDict
                                                                            context:_importContext];

            NSManagedObject *locationAtShop = [importer insertBasicObjectWithEntity:@"LocationShop"
                                                                    entityAttribute:@"locationAtShop"
                                                                       xmlAttribute:@"locationatshop"
                                                                 xmlAttributeValues:attributeDict
                                                                            context:_importContext];
            [item setValue:locationAtHome forKey:@"locationHome"];
            [item setValue:locationAtShop forKey:@"locationShop"];
            [item setValue:unit forKey:@"unit"];
            [item setValue:[NSNumber numberWithBool:NO] forKey:@"listed"];
            
            [importer saveContext:_importContext];
            
            NSLog(@"item = %@",item);
            
            [_importContext refreshObject:item mergeChanges:NO];
            [_importContext refreshObject:unit mergeChanges:NO];
            [_importContext refreshObject:locationAtShop mergeChanges:NO];
            [_importContext refreshObject:locationAtHome mergeChanges:NO];
            
        }
    }];
}
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"parser = %@",parser);
    
    [[NSNotificationCenter defaultCenter]postNotificationName:someThingChangedNotification object:nil];
}
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    NSLog(@"parser = %@",parser);
}

#pragma mark  - DEEP COPY

- (void)deepCopyFromPersistentStore:(NSURL *)sourceUrl
{
    //进行深拷贝的操作,深拷贝的操作是运行在_sourceContext的私有队列上的
    
    _importTimer = [NSTimer timerWithTimeInterval:2.0f target:self selector:@selector(somethingChanged) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:_importTimer forMode:NSRunLoopCommonModes];
    
    [_sourceContext performBlock:^{
        CoreDataImporter *importer = [[CoreDataImporter alloc]initWithEntitiesWithUniqueAttribute:[self selectedUniqueAttributes]];
        NSArray *entities = [NSArray arrayWithObjects:@"Item",@"LocationHome",@"LocationShop",@"Unit", nil];
        [importer deepCopyEntities:entities fromSoureceContext:_sourceContext toDestinationContext:_importContext];
        [_context performBlock:^{
            [_importTimer invalidate];
            _importTimer  = nil;
            [self somethingChanged];
        }];
    }];
}

- (void)somethingChanged
{
    [[NSNotificationCenter defaultCenter]postNotificationName:someThingChangedNotification object:nil];
}

#pragma mark - UNIQUE ATTRIBUTE SELECTION

- (NSDictionary *)selectedUniqueAttributes
{
    NSMutableArray *entities   = [NSMutableArray array];
    NSMutableArray *attributes = [NSMutableArray array];
    [entities addObject:@"Item"];
    [entities addObject:@"LocationHome"];
    [entities addObject:@"LocationShop"];
    [entities addObject:@"Unit"];
    [entities addObject:@"ItemPhoto"];
    [attributes addObject:@"name"];
    [attributes addObject:@"locationAtHome"];
    [attributes addObject:@"locationAtShop"];
    [attributes addObject:@"name"];
    [attributes addObject:@"data"];
    return [NSDictionary dictionaryWithObjects:attributes forKeys:entities];
}

#pragma mark - LOAD TEST DATA

- (void)importTestGeoceryData
{
    BOOL isTestDataLoaded = [[NSUserDefaults standardUserDefaults]boolForKey:@"TestData"];
    if (!isTestDataLoaded) {
        
        [_importContext performBlock:^{
            NSManagedObject *locationHome = [NSEntityDescription insertNewObjectForEntityForName:@"LocationHome" inManagedObjectContext:_importContext];
            [locationHome setValue:@"locationhometest" forKey:@"locationAtHome"];
            
            NSManagedObject *locationShop = [NSEntityDescription insertNewObjectForEntityForName:@"LocationShop" inManagedObjectContext:_importContext];
            [locationShop setValue:@"locationshoptest" forKey:@"locationAtShop"];
            

            
            for (int i = 0; i < 100; i++) {
                
                @autoreleasepool {
                    
                    NSManagedObject *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"ItemPhoto" inManagedObjectContext:_importContext];
                    [newPhoto setValue:UIImagePNGRepresentation([UIImage imageNamed:@"GroceryHead.png"]) forKey:@"data"];
                    
                    NSManagedObject *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:_importContext];
                    [item setValue:[NSString stringWithFormat:@"Test Item %d",i] forKey:@"name"];
                    [item setValue:locationShop forKey:@"locationShop"];
                    [item setValue:locationHome forKey:@"locationHome"];
                    [item setValue:newPhoto forKey:@"photo"];
                    [CoreDataImporter saveContext:_importContext];
                    [_importContext refreshObject:item mergeChanges:NO];
                    [_importContext refreshObject:newPhoto mergeChanges:NO];
                }
                
            }
            
            [_context performBlock:^{
                [self somethingChanged];
            }];
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"TestData"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }];
        
    }
}

#pragma mark - VALIDATION ERROR

- (void)showValidationError:(NSError *)anError
{
    if (anError.code && [anError.domain isEqualToString:@"NSCocoaErrorDomain"]) {
        NSArray *errors = nil;
        NSString *txt   = @"";

        if (anError.code == NSValidationMultipleErrorsError) {
            errors = [anError.userInfo objectForKey:NSDetailedErrorsKey];
        }else {
            errors = [NSArray arrayWithObject:anError];
        }
        
        //展示错误
        if (errors && [errors count] > 0) {
            for (NSError *err in errors) {
                NSString *entity = [[[[err userInfo]objectForKey:@"NSValidationErrorObject"] entity]name];
                
                NSString *property = [[err userInfo]objectForKey:@"NSValidationErrorKey"];
                
                switch (err.code) {
                    case NSValidationRelationshipDeniedDeleteError:
                        txt = [txt stringByAppendingFormat:@"%@ delete was denied because there are associate %@ \n(Error Code - %li)\n\n",entity,property,(long)err.code];
                        break;
                        
                    case NSValidationRelationshipLacksMinimumCountError:
                        txt = [txt stringByAppendingFormat:@"the '%@' relationship count is to few (Error code - %li)",property,(long)err.code];
                        break;
                        
                    case NSValidationRelationshipExceedsMaximumCountError:
                        txt = [txt stringByAppendingFormat:@"the '%@' relationship count is to large (Error code - %li)",property,(long)err.code];
                        break;
                        
                    case NSValidationMissingMandatoryPropertyError:
                        txt = [txt stringByAppendingFormat:@"the '%@' property is missing (Error code - %li)",property,(long)err.code];
                        break;
                        
                    case NSValidationNumberTooSmallError:
                        txt = [txt stringByAppendingFormat:@"the '%@' number is too small (Error code - %li)",property,(long)err.code];
                        break;
                        
                    case NSValidationNumberTooLargeError:
                        txt = [txt stringByAppendingFormat:@"the '%@' number is too large (Error cdoe - %li)",property,(long)err.code];
                        break;
                        
                    case NSValidationDateTooSoonError:
                        txt = [txt stringByAppendingFormat:@"the '%@' date is too soon (Error Code - %li)",property,(long)err.code];
                        break;
                        
                    case NSValidationDateTooLateError:
                        txt = [txt stringByAppendingFormat:@"the '%@' date is too late (Error Code - %li)",property,(long)err.code];
                        break;
                        
                    case NSValidationInvalidDateError:
                        txt = [txt stringByAppendingFormat:@"the '%@' date is invalid (Error Code - %li)",property,(long)err.code];
                        break;
                        
                    case NSValidationStringTooLongError:
                        txt = [txt stringByAppendingFormat:@"the '%@' text is too long (Error Code - %li)",property,(long)err.code];
                        break;
                        
                    case NSValidationStringTooShortError:
                        txt = [txt stringByAppendingFormat:@"the '%@' text is too short (Error Code - %li)",property,(long)err.code];
                        break;
                        
                    case NSValidationStringPatternMatchingError:
                        txt = [txt stringByAppendingFormat:@"the '%@' text doesn't match the specified pattern (Error Code - %li)",property,(long)err.code];
                        break;
                        
                    case NSManagedObjectValidationError:
                        txt = [txt stringByAppendingFormat:@"generated validation error (Error Code - %li)",(long)err.code];
                        break;
                        
                    default:
                        txt = [txt stringByAppendingFormat:@"unhandled error code %li in show validationError method",(long)err.code];
                        break;
                        
                }
            }
        }
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Validation Error" message:txt delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alert show];
    }
}
@end


