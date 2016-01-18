//
//  CoreDateTF.h
//  WBCoreData
//
//  Created by ChengYan on 15/9/24.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"
@class CoreDateTF;

@protocol WBTextFieldDelegate <NSObject>

@optional

- (void)WBTextFieldConfirmAtManagerObjectID:(NSManagedObjectID *)managerObjectID
                                  textField:(CoreDateTF *)tf;

- (void)WBTextFieldClearWithTextField:(CoreDateTF *)tf;
@end

@interface CoreDateTF : UITextField<UIPickerViewDelegate,UIKeyInput,UIPickerViewDataSource>

@property (nonatomic, assign) id <WBTextFieldDelegate> pickerDelegate;
@property (nonatomic, retain) UIPickerView        *pickerView;
@property (nonatomic, retain) UIToolbar           *toolBar;
@property (nonatomic, retain) NSArray             *pickerData;
@property (nonatomic, retain) NSManagedObjectID   *selectObjectID;
@property (nonatomic, assign) BOOL                showToolBar;

- (void)fetch;//abstract method, should override by subclass

- (void)selectDefaultRow;//abstract method,should override by subclass
@end
