//
//  ShopLocationTVC.m
//  WBCoreData
//
//  Created by ChengYan on 15/9/23.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import "ShopLocationTVC.h"
#import "CoreDataHelper.h"
#import "ShopLocationViewController.h"
#import "LocationShop.h"
#import "AppDelegate.h"

@interface ShopLocationTVC ()
- (void)configureFetch;
- (IBAction)done:(id)sender;

@end

@implementation ShopLocationTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureFetch];
    [self performFetch];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(performFetch)
                                                name:someThingChangedNotification
                                              object:nil];
}


- (void)configureFetch
{
    AppDelegate *app             = [[UIApplication sharedApplication]delegate];
    CoreDataHelper *cdh          = [app cdh];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"LocationShop"];
    NSSortDescriptor *sort       = [NSSortDescriptor sortDescriptorWithKey:@"locationAtShop" ascending:YES];
    fetchRequest.sortDescriptors = @[sort];
    fetchRequest.fetchBatchSize  = 50;
    
    self.frc                     = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest
                                                                      managedObjectContext:cdh.context
                                                                        sectionNameKeyPath:nil
                                                                                 cacheName:nil];
    
}

- (IBAction)done:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ShopLocationViewController *unitViewCtl = [segue destinationViewController];
    
    if ([segue.identifier isEqualToString:@"AddShopLocation"]) {
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate] cdh];
        LocationShop *shop  = [NSEntityDescription insertNewObjectForEntityForName:@"LocationShop" inManagedObjectContext:cdh.context];
        NSError *error      = nil;
        if (![[cdh context]obtainPermanentIDsForObjects:@[shop] error:&error]) {
            NSLog(@"error %@",error.localizedDescription);
        }
        unitViewCtl.selectItemID = shop.objectID;
    }else if ([segue.identifier isEqualToString:@"EditShopLocation"]){
        NSIndexPath *indexPath   = [self.tableView indexPathForSelectedRow];
        unitViewCtl.selectItemID = [[self.frc objectAtIndexPath:indexPath]objectID];
    }else{
        NSLog(@"some error is occupy");
    }
}

#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"ShopLocationCell";
    UITableViewCell *cell       = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    LocationShop *shop          = (LocationShop *)[self.frc objectAtIndexPath:indexPath];

    NSString *title             = [[shop locationAtShop]stringByReplacingOccurrencesOfString:@"(null)"
                                                                        withString:@""
                                                                           options:0
                                                                             range:NSMakeRange(0, shop.locationAtShop.length)];
    cell.textLabel.text         = title;
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LocationShop *obj = [self.frc objectAtIndexPath:indexPath];
        [self.frc.managedObjectContext deleteObject:obj];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


@end
