//
//  HomeLocationViewController.m
//  WBCoreData
//
//  Created by ChengYan on 15/9/23.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import "HomeLocationViewController.h"
#import "AppDelegate.h"
#import "CoreDataHelper.h"
#import "LocationHome.h"

@interface HomeLocationViewController ()<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
- (void)refreshView;
- (void)hideKeyboardWhenBackgroundIsTapped;
@end

@implementation HomeLocationViewController

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
    LocationHome *home      = (LocationHome *)[[cdh context]existingObjectWithID:self.selectItemID error:nil];
    self.nameTextField.text = home.locationAtHome;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    AppDelegate *app    = [[UIApplication sharedApplication]delegate];
    CoreDataHelper *cdh = [app cdh];
    LocationHome *home  = (LocationHome *)[[cdh context]existingObjectWithID:self.selectItemID error:nil];
    
    if (textField == self.nameTextField) {
        home.locationAtHome = self.nameTextField.text;
        [[NSNotificationCenter defaultCenter]postNotificationName:someThingChangedNotification
                                                           object:nil];
    }
}


@end
