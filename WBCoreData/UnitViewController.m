//
//  UnitViewController.m
//  WBCoreData
//
//  Created by ChengYan on 15/9/22.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import "UnitViewController.h"
#import "AppDelegate.h"
#import "Unit.h"

@interface UnitViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
- (void)refreshView;
- (void)hideKeyboardWhenBackgroundIsTapped;
@end

@implementation UnitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideKeyboardWhenBackgroundIsTapped];
    self.nameTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshView];
    [self.nameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideKeyboardWhenBackgroundIsTapped
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    tap.cancelsTouchesInView    = NO;
    tap.numberOfTapsRequired    = 1;
    [self.view addGestureRecognizer:tap];
}

- (void)hideKeyboard
{
    [self.view endEditing:YES];
}

- (void)refreshView
{
    AppDelegate *app        = [[UIApplication sharedApplication]delegate];
    CoreDataHelper *cdh     = [app cdh];
    Unit *unit              = (Unit *)[[cdh context]existingObjectWithID:self.selectItemID error:nil];
    self.nameTextField.text = unit.name;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    AppDelegate *app        = [[UIApplication sharedApplication]delegate];
    CoreDataHelper *cdh     = [app cdh];
    Unit *unit              = (Unit *)[[cdh context]existingObjectWithID:self.selectItemID error:nil];
    
    if (textField == self.nameTextField) {
        unit.name = self.nameTextField.text;
        [[NSNotificationCenter defaultCenter]postNotificationName:someThingChangedNotification
                                                           object:nil];
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

@end
