//
//  UnitTF.m
//  WBCoreData
//
//  Created by ChengYan on 15/9/24.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import "UnitTF.h"
#import "CoreDataHelper.h"
#import "Unit.h"
#import "AppDelegate.h"

@implementation UnitTF

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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Unit"];
    fetchRequest.fetchBatchSize  = 50;
    
    NSSortDescriptor *sort       = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    fetchRequest.sortDescriptors = @[sort];
    
    self.pickerData              = [[cdh context]executeFetchRequest:fetchRequest error:nil];
    
    [self selectDefaultRow];
}

- (void)selectDefaultRow
{
    if ([self.pickerData count] > 0 && self.selectObjectID) {
        AppDelegate *app = [[UIApplication sharedApplication]delegate];
        CoreDataHelper *cdh = [app cdh];
        Unit *unit = (Unit *)[[cdh context]existingObjectWithID:self.selectObjectID error:nil];
        
        [self.pickerData enumerateObjectsUsingBlock:^(Unit *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.name compare:unit.name] == NSOrderedSame) {
                [self.pickerView selectRow:idx inComponent:0 animated:NO];
                [self.pickerDelegate WBTextFieldConfirmAtManagerObjectID:unit.objectID textField:self];
                *stop = YES;
            }
        }];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Unit *unit = [self.pickerData objectAtIndex:row];
    return unit.name;
}
@end
