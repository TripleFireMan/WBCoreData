//
//  AppDelegate.m
//  WBCoreData
//
//  Created by ChengYan on 15/8/4.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "Item.h"
#import "LocationShop.h"
#import "LocationHome.h"
#import "Measurement.h"
#import "Account.h"
#import "Unit.h"
#define debug   1

@interface AppDelegate ()
@property (nonatomic, strong) CoreDataHelper *cdh;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[self cdh]saveContext];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self cdh];
//    [self demo];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[self cdh]saveContext];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (CoreDataHelper *)cdh
{
    if (debug) {
        NSLog(@"Running %@ '%@'",[self class],NSStringFromSelector(_cmd));
    }
    
    if (!_cdh) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _cdh = [CoreDataHelper new];
            
        });
        [_cdh setupCoreData];
    }
    return _cdh;
}

- (void)demo
{
    if (debug) {
        NSLog(@"Running %@ '%@'",[self class],NSStringFromSelector(_cmd));
    }
    
//    for (int i = 0; i < 5000; i++) {
//        Measurement *measurement = [NSEntityDescription insertNewObjectForEntityForName:@"Measurement" inManagedObjectContext:[[self cdh] context]];
//        measurement.name = [NSString stringWithFormat:@"index = %d",i];
//        NSLog(@"name = %@",measurement.name);
//    }
//    [[self cdh]saveContext];
    
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Measurement"];
//    request.fetchLimit = 50;
//    NSArray *result = [[[self cdh]context]executeFetchRequest:request error:nil];
//    for (int i = 0; i < [result count]; i++) {
//        Measurement *measurement = [result objectAtIndex:i];
//        NSLog(@"name = %@",measurement.name);
//    }
    
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Account"];
//    request.fetchLimit = 50;
//    NSArray *result = [[[self cdh]context]executeFetchRequest:request error:nil];
//    for (int i = 0; i < [result count]; i++) {
//        Account *account = [result objectAtIndex:i];
//        NSLog(@"name = %@",account.xyz);
//    }
    
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
//    request.fetchLimit = 50;
//    NSArray *result = [[[self cdh]context]executeFetchRequest:request error:nil];
//    for (int i = 0; i < [result count]; i++) {
//        Unit *unit = [result objectAtIndex:i];
//        NSLog(@"unit name = %@",unit.name);
//    }
    
//    Unit *kg = [NSEntityDescription insertNewObjectForEntityForName:@"Unit" inManagedObjectContext:[[self cdh] context]];
//    kg.name = @"KG";
//    
//    Item *bananer = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:[[self cdh] context]];
//    bananer.unit = kg;
//    bananer.name = @"bananer";
//    
//    Item *oranger = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:[[self cdh] context]];
//    oranger.unit = kg;
//    oranger.name = @"Oranger";
//    
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
//    NSArray *result = [[[self cdh]context] executeFetchRequest:request error:nil];
//    for (Item *item in result) {
//        if (debug) {
//            NSLog(@"item.name = %@",item.name);
//        }
//    }
//
//    [[self cdh]saveContext];
    
    
//    [self showItemAndUnitCount];
//    
//    NSFetchRequest *fetchUnit = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
//    NSPredicate *filter = [NSPredicate predicateWithFormat:@"name = %@",@"KG"];
//    [fetchUnit setPredicate:filter];
//    
//    NSArray *result = [[[self cdh] context] executeFetchRequest:fetchUnit error:nil];
//    
//    for (Unit *u in result) {
//        NSError *error = nil;
//        if ([u validateForDelete:&error]) {
//            if (debug) {
//                NSLog(@"Delete entity name : %@",u.name);
//            }
//            [[[self cdh] context] deleteObject:u];
//        }else{
//            if (debug) {
//                NSLog(@"Skipped delete %@,error : %@",u.name,error);
//            }
//            if (error) {
//                [[self cdh]showValidationError:error];
//            }
//        }
//    }
//    
//    [self showItemAndUnitCount];
//    [[self cdh] saveContext];
    
    
    //
    CoreDataHelper *cdh    = [self cdh];

    NSArray *homeLocations = @[@"果盘",@"冰箱",@"柜子",@"卫生间",@"厨房"];
    NSArray *shopLocations = @[@"家乐福",@"物美",@"超市发",@"美特好",@"唐久"];
    NSArray *unitNames     = @[@"g",@"pkt",@"box",@"ml",@"kg"];
    NSArray *items         = @[@"葡萄",@"苹果",@"橘子",@"香蕉",@"桃"];
    
    int i = 0 ;
    for (NSString *itemName in items) {
        LocationHome *home  = [NSEntityDescription insertNewObjectForEntityForName:@"LocationHome" inManagedObjectContext:cdh.context];
        LocationShop *shop  = [NSEntityDescription insertNewObjectForEntityForName:@"LocationShop" inManagedObjectContext:cdh.context];
        Unit *unit          = [NSEntityDescription insertNewObjectForEntityForName:@"Unit" inManagedObjectContext:cdh.context];
        Item *item          = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:cdh.context];
        home.locationAtHome = [homeLocations objectAtIndex:i];
        shop.locationAtShop = [shopLocations objectAtIndex:i];
        unit.name           = [unitNames objectAtIndex:i];
        item.locationHome   = home;
        item.locationShop   = shop;
        item.unit           = unit;
        item.name           = itemName;
        i++;
    }
    [cdh saveContext];
}

- (void)showItemAndUnitCount
{
    if (debug) {
        NSLog(@"Running %@ '%@'",[self class],NSStringFromSelector(_cmd));
    }

    NSError *error             = nil;
    NSFetchRequest *fetchItems = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    NSArray *items             = [[[self cdh]context] executeFetchRequest:fetchItems error: &error];

    if (error) {
        if (debug) {
            NSLog(@"failed fetch items");
        }
    }else {
        if (debug) {
            NSLog(@"Items count : %ld",(long)[items count]);
        }
    }

    error                      = nil;
    NSFetchRequest *fetchUnit  = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    NSArray *units             = [[[self cdh] context] executeFetchRequest:fetchUnit error:&error];

    if (error) {
        if (debug) {
            NSLog(@"faile fetch unit");
        }
    }else {
        if (debug) {
            NSLog(@"unit count : %ld",(long)[units count]);
        }
    }
}
@end
