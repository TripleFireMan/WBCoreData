//
//  LocationHomeTF.m
//  WBCoreData
//
//  Created by ChengYan on 15/9/24.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import "LocationHomeTF.h"
#import "CoreDataHelper.h"
#import "LocationHome.h"
#import "AppDelegate.h"
@implementation LocationHomeTF

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)fetch
{
    AppDelegate *app             = [[UIApplication sharedApplication]delegate];
    CoreDataHelper *cdh          = [app cdh];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"LocationHome"];
    fetchRequest.fetchBatchSize  = 50;
    
    NSSortDescriptor *sort       = [NSSortDescriptor sortDescriptorWithKey:@"locationAtHome" ascending:YES];
    fetchRequest.sortDescriptors = @[sort];
    
    self.pickerData              = [[cdh context]executeFetchRequest:fetchRequest error:nil];
    
    [self selectDefaultRow];
}

- (void)selectDefaultRow
{
    if ([self.pickerData count] > 0 && self.selectObjectID) {
        AppDelegate *app = [[UIApplication sharedApplication]delegate];
        CoreDataHelper *cdh = [app cdh];
        LocationHome *home = (LocationHome *)[[cdh context]existingObjectWithID:self.selectObjectID error:nil];
        
        [self.pickerData enumerateObjectsUsingBlock:^(LocationHome *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.locationAtHome compare:home.locationAtHome] == NSOrderedSame) {
                [self.pickerView selectRow:idx inComponent:0 animated:NO];
                [self.pickerDelegate WBTextFieldConfirmAtManagerObjectID:home.objectID textField:self];
                *stop = YES;
            }
        }];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    LocationHome *home = [self.pickerData objectAtIndex:row];
    return home.locationAtHome;
}
@end
