//
//  PrepareViewController.h
//  WBCoreData
//
//  Created by ChengYan on 15/9/14.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import "CoreDataTVC.h"

@interface PrepareViewController : CoreDataTVC <UIActionSheetDelegate>

@property (nonatomic, strong) UIActionSheet *clearConfirmActionSheet;

@end
