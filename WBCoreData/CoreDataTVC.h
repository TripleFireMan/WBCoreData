//
//  CoreDataTVC.h
//  WBCoreData
//
//  Created by ChengYan on 15/9/1.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

@interface CoreDataTVC : UITableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *frc;

- (void)performFetch;

@end
