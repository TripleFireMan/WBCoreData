//
//  ShopLocationViewController.m
//  WBCoreData
//
//  Created by ChengYan on 15/9/23.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import "ShopLocationViewController.h"
#import "AppDelegate.h"
#import "LocationShop.h"

@interface ShopLocationViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *nameTextField;

- (void)refreshView;
- (void)hideKeyboardWhenBackgroundIsTapped;

@end

@implementation ShopLocationViewController

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
    LocationShop *shop      = (LocationShop *)[[cdh context]existingObjectWithID:self.selectItemID error:nil];
    self.nameTextField.text = shop.locationAtShop;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    AppDelegate *app    = [[UIApplication sharedApplication]delegate];
    CoreDataHelper *cdh = [app cdh];
    LocationShop *shop  = (LocationShop *)[[cdh context]existingObjectWithID:self.selectItemID error:nil];
    
    if (textField == self.nameTextField) {
        shop.locationAtShop = self.nameTextField.text;
        [[NSNotificationCenter defaultCenter]postNotificationName:someThingChangedNotification
                                                           object:nil];
    }
}

@end
