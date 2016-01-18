//
//  AppDelegate.h
//  WBCoreData
//
//  Created by ChengYan on 15/8/4.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const someThingChangedNotification;

@class CoreDataHelper;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (CoreDataHelper *)cdh;//放在这里面执行的原因，是确保context是在主线程中
@end

