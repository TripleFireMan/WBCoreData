//
//  LocationShopTF.m
//  WBCoreData
//
//  Created by ChengYan on 15/9/24.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import "LocationShopTF.h"
#import "CoreDataHelper.h"
#import "LocationShop.h"
#import "AppDelegate.h"
@implementation LocationShopTF

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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"LocationShop"];
    fetchRequest.fetchBatchSize  = 50;
    
    NSSortDescriptor *sort       = [NSSortDescriptor sortDescriptorWithKey:@"locationAtShop" ascending:YES];
    fetchRequest.sortDescriptors = @[sort];
    
    self.pickerData              = [[cdh context]executeFetchRequest:fetchRequest error:nil];
    
    [self selectDefaultRow];
}

- (void)selectDefaultRow
{
    if ([self.pickerData count] > 0 && self.selectObjectID) {
        AppDelegate *app = [[UIApplication sharedApplication]delegate];
        CoreDataHelper *cdh = [app cdh];
        LocationShop *Shop = (LocationShop *)[[cdh context]existingObjectWithID:self.selectObjectID error:nil];
        
        [self.pickerData enumerateObjectsUsingBlock:^(LocationShop *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.locationAtShop compare:Shop.locationAtShop] == NSOrderedSame) {
                [self.pickerView selectRow:idx inComponent:0 animated:NO];
                [self.pickerDelegate WBTextFieldConfirmAtManagerObjectID:Shop.objectID textField:self];
                *stop = YES;
            }
        }];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    LocationShop *Shop = [self.pickerData objectAtIndex:row];
    return Shop.locationAtShop;
}
@end
