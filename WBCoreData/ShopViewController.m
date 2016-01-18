//
//  ShopViewController.m
//  WBCoreData
//
//  Created by ChengYan on 15/9/14.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import "ShopViewController.h"
#import "CoreDataHelper.h"
#import "Item.h"
#import "LocationShop.h"
#import "Unit.h"
#import "AppDelegate.h"
#import "ItemViewController.h"
#import "ItemPhoto.h"
@interface ShopViewController ()
- (IBAction)clear:(id)sender;

@end

@implementation ShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureFetch];
    [self performFetch];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(performFetch) name:@"someThingChanged" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureFetch
{
    CoreDataHelper *cdh               = [(AppDelegate *)[UIApplication sharedApplication].delegate cdh];

    NSFetchRequest *fetchRequest      = [[[cdh model]fetchRequestTemplateForName:@"ShoppingList"]copy];
    NSSortDescriptor *sortDescriptor  = [NSSortDescriptor sortDescriptorWithKey:@"locationShop.locationAtShop" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor,sortDescriptor2]];
    [fetchRequest setFetchBatchSize:10];

    self.frc          = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest
                                                  managedObjectContext:cdh.context
                                                    sectionNameKeyPath:@"locationShop.locationAtShop"
                                                             cacheName:nil];
    self.frc.delegate = self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"shopCell";
    UITableViewCell *cell       = [tableView dequeueReusableCellWithIdentifier:identifier];

    Item *item                  = [self.frc objectAtIndexPath:indexPath];

    NSMutableString *title      = [NSMutableString stringWithFormat:@"%@%@ %@",item.quantity,item.unit.name,item.name];
    [title replaceOccurrencesOfString:@"(null)" withString:@"" options:0 range:NSMakeRange(0, title.length)];
    cell.textLabel.text         = title;

    if ([item.collected boolValue]) {
    cell.textLabel.font         = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor    = [UIColor colorWithRed:0.36 green:0.74 blue:0.34 alpha:1];
    cell.accessoryType          = UITableViewCellAccessoryCheckmark;
    }else{
    cell.textLabel.font         = [UIFont systemFontOfSize:18];
    cell.textLabel.textColor    = [UIColor orangeColor];
    cell.accessoryType          = UITableViewCellAccessoryDetailButton;
    }
    cell.imageView.image        = [UIImage imageWithData:item.photo.data];
    return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Item *item = [self.frc objectAtIndexPath:indexPath];
    if ([item.collected boolValue]) {
        item.collected = [NSNumber numberWithBool:NO];
    }else{
        item.collected = [NSNumber numberWithBool:YES];
    }
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ItemViewController *itemVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemViewController"];
    itemVC.selectItemID        = [[self.frc objectAtIndexPath:indexPath]objectID];
    [self.navigationController pushViewController:itemVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clear:(id)sender
{
    if ([self.frc.fetchedObjects count] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示"
                                                           message:@"没有需要清空的物品"
                                                          delegate:nil
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    BOOL nothingCleared = YES;
    
    for (Item *item in self.frc.fetchedObjects) {
        if ([item.collected boolValue]) {
            item.listed    = [NSNumber numberWithBool:NO];
            item.collected = [NSNumber numberWithBool:NO];
            nothingCleared = NO;
        }
    }
    
    if (nothingCleared) {
        UIAlertView *alertview = [[UIAlertView alloc]initWithTitle:@"提示"
                                                           message:@"请选择要清除的物品先"
                                                          delegate:nil
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil, nil];
        [alertview show];
    }
}
@end
