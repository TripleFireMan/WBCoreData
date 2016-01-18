//
//  CoreDateTF.m
//  WBCoreData
//
//  Created by ChengYan on 15/9/24.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import "CoreDateTF.h"

@interface CoreDateTF ()

- (UIView *)createInputView;
- (UIView *)createInputAccessoryView;

@end

@implementation CoreDateTF

#pragma mark - LIFECYCLE

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.inputView          = [self createInputView];
        self.inputAccessoryView = [self createInputAccessoryView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.inputView          = [self createInputView];
        self.inputAccessoryView = [self createInputAccessoryView];
    }
    return self;
}

#pragma mark - DATA

- (void)fetch
{
    [NSException raise:NSInternalInconsistencyException
                format:@"you must override the '%@' method to provide data to the picker",NSStringFromSelector(_cmd)];
}

- (void)selectDefaultRow
{
    [NSException raise:NSInternalInconsistencyException
                format:@"you must override the '%@' method to provide data to the picker",NSStringFromSelector(_cmd)];
}


#pragma mark - DELEGATE&DATASOURCE
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.pickerData count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 44.f;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 280.f;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([self.pickerData count]>0) {
        NSManagedObject *managerdObject = [self.pickerData objectAtIndex:row];
        [self.pickerDelegate WBTextFieldConfirmAtManagerObjectID:managerdObject.objectID textField:self];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.pickerData objectAtIndex:row];
}

#pragma mark - VIEW

- (UIView *)createInputAccessoryView
{
    self.showToolBar = YES;
    
    if (!self.toolBar && self.showToolBar) {
        self.toolBar                  = [[UIToolbar alloc]init];
        self.toolBar.barStyle         = UIBarStyleBlackTranslucent;
        self.toolBar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        CGRect frame                  = self.toolBar.frame;
        [self.toolBar sizeToFit];
        frame.size.height             = 44;
        self.toolBar.frame            = frame;

        UIBarButtonItem *clear        = [[UIBarButtonItem alloc]initWithTitle:@"clear" style:UIBarButtonItemStylePlain target:self action:@selector(clear)];
        UIBarButtonItem *space        = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *done         = [[UIBarButtonItem alloc]initWithTitle:@"done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
        self.toolBar.items            = [NSArray arrayWithObjects:clear,space,done, nil];
    }
    return self.toolBar;
    
}

- (UIView *)createInputView
{
    self.pickerView                         = [[UIPickerView alloc]initWithFrame:CGRectZero];
    self.pickerView.dataSource              = self;
    self.pickerView.delegate                = self;
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.autoresizingMask        = UIViewAutoresizingFlexibleHeight;
    [self fetch];
    return self.pickerView;
}

#pragma mark - INTERACTION

- (void)clear
{
    [self.pickerDelegate WBTextFieldClearWithTextField:self];
    [self resignFirstResponder];
}

- (void)done
{
    [self resignFirstResponder];
}

- (void)deviceDidRotate:(NSNotification *)notification
{
    [self.pickerView setNeedsLayout];
}
@end
