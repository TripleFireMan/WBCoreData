//
//  UnitTableViewController.m
//  WBCoreData
//
//  Created by ChengYan on 15/9/18.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import "UnitTableViewController.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "Unit.h"
#import "UnitViewController.h"

@interface UnitTableViewController ()
- (void)configureFetch;
- (IBAction)done:(id)sender;

@end

@implementation UnitTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureFetch];
    [self performFetch];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(performFetch)
                                                name:someThingChangedNotification
                                              object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UnitViewController *unitViewCtl = [segue destinationViewController];
    
    if ([segue.identifier isEqualToString:@"AddUnit"]) {
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate] cdh];
        Unit *unit          = [NSEntityDescription insertNewObjectForEntityForName:@"Unit" inManagedObjectContext:cdh.context];
        NSError *error      = nil;
        if (![[cdh context]obtainPermanentIDsForObjects:@[unit] error:&error]) {
            NSLog(@"error %@",error.localizedDescription);
        }
        unitViewCtl.selectItemID = unit.objectID;
    }else if ([segue.identifier isEqualToString:@"EditUnit"]){
        NSIndexPath *indexPath   = [self.tableView indexPathForSelectedRow];
        unitViewCtl.selectItemID = [[self.frc objectAtIndexPath:indexPath]objectID];
    }else{
        NSLog(@"some error is occupy");
    }
}

- (void)configureFetch
{
    AppDelegate *app             = [[UIApplication sharedApplication]delegate];
    CoreDataHelper *cdh          = [app cdh];

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    NSSortDescriptor *sort       = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
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

#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"UnitCell";
    UITableViewCell *cell       = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    Unit *unit                  = (Unit *)[self.frc objectAtIndexPath:indexPath];

    NSString *title             = [[unit name]stringByReplacingOccurrencesOfString:@"(null)"
                                                            withString:@""
                                                               options:0
                                                                 range:NSMakeRange(0, unit.name.length)];
    cell.textLabel.text         = title;
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Unit *obj = [self.frc objectAtIndexPath:indexPath];
        [self.frc.managedObjectContext deleteObject:obj];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
