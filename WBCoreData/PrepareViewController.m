//
//  PrepareViewController.m
//  WBCoreData
//
//  Created by ChengYan on 15/9/14.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import "PrepareViewController.h"
#import "Item.h"
#import "Unit.h"
#import "AppDelegate.h"
#import "ItemViewController.h"
#import "ItemPhoto.h"

@interface PrepareViewController ()
- (IBAction)clear:(id)sender;

@end

@implementation PrepareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureFetch];
    [self performFetch];
    self.clearConfirmActionSheet.delegate = self;
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(performFetch)
                                                name:someThingChangedNotification
                                              object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)configureFetch
{
    AppDelegate *appDelegate     = [UIApplication sharedApplication].delegate;

    CoreDataHelper *coredataHelp = [appDelegate cdh];

    NSFetchRequest *request      = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    NSSortDescriptor *soutDes    = [NSSortDescriptor sortDescriptorWithKey:@"locationHome.locationAtHome" ascending:YES];
    NSSortDescriptor *soutDes1   = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    [request setSortDescriptors:@[soutDes,soutDes1]];
    [request setFetchBatchSize:20];//这个FetchBatchSize仅仅是context从数据库中批量读取时的一个值
    
    if (!self.frc) {
        self.frc = [[NSFetchedResultsController alloc]initWithFetchRequest:request
                                                      managedObjectContext:coredataHelp.context
                                                        sectionNameKeyPath:@"locationHome.locationAtHome"
                                                                 cacheName:nil];
    }
    self.frc.delegate = self;
}

#pragma - VIEW

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"prepareCell";
    UITableViewCell *cell       = [tableView dequeueReusableCellWithIdentifier:identifier];
//    cell.accessoryType          = UITableViewCellAccessoryDetailButton;

    Item *item                  = (Item *)[self.frc objectAtIndexPath:indexPath];
    NSMutableString *title      = [NSMutableString stringWithFormat:@"%@%@ %@",item.quantity,item.unit.name,item.name];
    [title replaceOccurrencesOfString:@"(null)" withString:@"" options:0 range:NSMakeRange(0, title.length)];
    cell.textLabel.text         = title;

    if ([item.listed boolValue]) {
        cell.textLabel.font      = [UIFont fontWithName:@"Helvetica Neue" size:18];
        cell.textLabel.textColor = [UIColor orangeColor];
    }else{
        cell.textLabel.font      = [UIFont fontWithName:@"Helvtica Neue" size:16];
        cell.textLabel.textColor = [UIColor grayColor];
    }
    cell.imageView.image        = [UIImage imageWithData:item.photo.data];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Item *obj = [self.frc objectAtIndexPath:indexPath];
        [self.frc.managedObjectContext deleteObject:obj];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectID *objectID = [[self.frc objectAtIndexPath:indexPath]objectID];
    Item *item                  = (Item *)[[self.frc managedObjectContext]existingObjectWithID:objectID error:nil];
    
    if ([[item listed]boolValue]) {
        item.listed    = [NSNumber numberWithBool:NO];
    }else{
        item.listed    = [NSNumber numberWithBool:YES];
        item.collected = [NSNumber numberWithBool:NO];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return nil;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    ItemViewController *itemVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemViewController"];
    itemVC.selectItemID        = [[self.frc objectAtIndexPath:indexPath]objectID];
    [self.navigationController pushViewController:itemVC animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ItemViewController *viewCtl = [segue destinationViewController];
    if ([segue.identifier isEqualToString:@"ItemViewController"]) {
        NSLog(@"NiuBi");
        
        CoreDataHelper *cdh  = [(AppDelegate *)[UIApplication sharedApplication].delegate cdh];
        Item *item           = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:cdh.context];

        NSError *error       = nil;

        if (![cdh.context obtainPermanentIDsForObjects:@[item] error:&error]) {
            NSLog(@"could obtain permanent ID for object %@",error);
        }
        viewCtl.selectItemID = [item objectID];
    }
}

- (IBAction)clear:(id)sender
{
    CoreDataHelper *cdh          = [(AppDelegate *)[UIApplication sharedApplication].delegate cdh];
    NSFetchRequest *fetchRequest = [[cdh model]fetchRequestTemplateForName:@"ShoppingList"];
    NSArray *shoppingLists       = [[cdh context]executeFetchRequest:fetchRequest error:nil];
    
    if ([shoppingLists count] != 0) {
        self.clearConfirmActionSheet = [[UIActionSheet alloc]initWithTitle:@"清除所有已选择物品？"
                                                                  delegate:self
                                                         cancelButtonTitle:@"取消"
                                                    destructiveButtonTitle:@"删除"
                                                         otherButtonTitles:nil, nil];
        [self.clearConfirmActionSheet showFromTabBar:self.navigationController.tabBarController.tabBar];
    }else{
        UIAlertView *alertView       = [[UIAlertView alloc]initWithTitle:@"提示"
                                                           message:@"没有可以删除的商品"
                                                          delegate:nil
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil, nil];
        [alertView show];
    }
    shoppingLists = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet == self.clearConfirmActionSheet) {
        if (buttonIndex == [actionSheet destructiveButtonIndex]) {
            [self clearList];
        }else if(buttonIndex == [actionSheet cancelButtonIndex]){
            [actionSheet dismissWithClickedButtonIndex:[actionSheet cancelButtonIndex] animated:YES];
        }
    }
}

- (void)clearList
{
    CoreDataHelper *cdh     = [(AppDelegate *)[UIApplication sharedApplication].delegate cdh];
    NSFetchRequest *request = [[cdh model]fetchRequestTemplateForName:@"ShoppingList"];
    NSArray *shoppingList   = [[cdh context]executeFetchRequest:request error:nil];
    for (Item *item in shoppingList) {
        item.listed = [NSNumber numberWithBool:NO];
    }
}
@end
