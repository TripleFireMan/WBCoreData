//
//  HomeLocationTVC.m
//  WBCoreData
//
//  Created by ChengYan on 15/9/23.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import "HomeLocationTVC.h"
#import "CoreDataHelper.h"
#import "HomeLocationViewController.h"
#import "LocationHome.h"
#import "AppDelegate.h"

@interface HomeLocationTVC ()
- (void)configureFetch;
- (IBAction)done:(id)sender;

@end

@implementation HomeLocationTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureFetch];
    [self performFetch];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(performFetch)
                                                name:someThingChangedNotification
                                              object:nil];
    // Do any additional setup after loading the view.
}


- (void)configureFetch
{
    AppDelegate *app             = [[UIApplication sharedApplication]delegate];
    CoreDataHelper *cdh          = [app cdh];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"LocationHome"];
    NSSortDescriptor *sort       = [NSSortDescriptor sortDescriptorWithKey:@"locationAtHome" ascending:YES];
    fetchRequest.sortDescriptors = @[sort];
    fetchRequest.fetchBatchSize  = 50;
    
    self.frc                     = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest
                                                                      managedObjectContext:cdh.context
                                                                        sectionNameKeyPath:nil
                                                                                 cacheName:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    HomeLocationViewController *unitViewCtl = [segue destinationViewController];
    
    if ([segue.identifier isEqualToString:@"AddHomeLocation"]) {
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate] cdh];
        LocationHome *home  = [NSEntityDescription insertNewObjectForEntityForName:@"LocationHome" inManagedObjectContext:cdh.context];
        NSError *error      = nil;
        if (![[cdh context]obtainPermanentIDsForObjects:@[home] error:&error]) {
            NSLog(@"error %@",error.localizedDescription);
        }
        unitViewCtl.selectItemID = home.objectID;
    }else if ([segue.identifier isEqualToString:@"EditHomeLocation"]){
        NSIndexPath *indexPath   = [self.tableView indexPathForSelectedRow];
        unitViewCtl.selectItemID = [[self.frc objectAtIndexPath:indexPath]objectID];
    }else{
        NSLog(@"some error is occupy");
    }
}

#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"HomeLocationCell";
    UITableViewCell *cell       = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    LocationHome *home          = (LocationHome *)[self.frc objectAtIndexPath:indexPath];
    
    NSString *title             = [[home locationAtHome]stringByReplacingOccurrencesOfString:@"(null)"
                                                                                  withString:@""
                                                                                     options:0
                                                                                       range:NSMakeRange(0, home.locationAtHome.length)];
    cell.textLabel.text         = title;
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LocationHome *obj = [self.frc objectAtIndexPath:indexPath];
        [self.frc.managedObjectContext deleteObject:obj];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)done:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}
@end
