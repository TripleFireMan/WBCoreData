
//
//  ItemViewController.m
//  WBCoreData
//
//  Created by ChengYan on 15/9/18.
//  Copyright (c) 2015年 chengyan. All rights reserved.
//

#import "ItemViewController.h"
#import "CoreDataHelper.h"
#import "AppDelegate.h"
#import "Item.h"
#import "LocationHome.h"
#import "LocationShop.h"
#import "UnitTF.h"  
#import "Unit.h"
#import "LocationHomeTF.h"
#import "LocationShopTF.h"
#import "ItemPhoto.h"

@interface ItemViewController ()<UITextFieldDelegate,WBTextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *scrollerView;
@property (weak, nonatomic  ) IBOutlet UITextField  *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField  *quantityTextField;
@property (strong, nonatomic) IBOutlet UnitTF       *unitTextField;
@property (strong, nonatomic) IBOutlet UnitTF       *homeTextField;
@property (strong, nonatomic) IBOutlet UnitTF       *shopTextField;
@property (strong, nonatomic) IBOutlet UIButton     *cameraBtn;
@property (strong, nonatomic) IBOutlet UIImageView  *photoImageView;

@property (assign, nonatomic) UITextField             *activeTextField;
@property (strong, nonatomic) UIImagePickerController *imagePickerCtl;


- (void)refreshView;
- (void)hideKeyBoardWhenBackgroundIsTapped;
- (void)ensureHomeLocationIsNotNil;
- (void)ensureShopLocationIsNotNil;

- (void)addKeyBoardNotification;
- (void)removeKeyBoardNotification;

/*!
 *  @brief  检查照相机或相册是否可用
 */
- (BOOL)checkCameraOrPhotoAlbumAvailable;
- (IBAction)takePhoto:(id)sender;

@end

@implementation ItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshView];
    [self hideKeyBoardWhenBackgroundIsTapped];
    self.nameTextField.delegate       = self;
    self.quantityTextField.delegate   = self;
    self.unitTextField.delegate       = self;
    self.unitTextField.pickerDelegate = self;
    self.shopTextField.delegate       = self;
    self.shopTextField.pickerDelegate = self;
    self.homeTextField.delegate       = self;
    self.homeTextField.pickerDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self ensureHomeLocationIsNotNil];
    [self ensureShopLocationIsNotNil];
    
    if ([self.nameTextField.text isEqualToString:@"New Item"]) {
        self.nameTextField.text = nil;
        [self.nameTextField becomeFirstResponder];
    }

    [self addKeyBoardNotification];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self ensureHomeLocationIsNotNil];
    [self ensureShopLocationIsNotNil];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    CoreDataHelper *cdh      = [appDelegate cdh];
    [cdh saveContext];
    
    [self removeKeyBoardNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshView
{
    AppDelegate *app            = [[UIApplication sharedApplication]delegate];
    CoreDataHelper *cdh         = [app cdh];

    NSError *error              = nil;
    Item *item                  = (Item *)[[cdh context]existingObjectWithID:self.selectItemID error:&error];
   
    if (error) {
        NSLog(@"cannot find item %@",error);
    }
    self.nameTextField.text           = item.name;
    self.quantityTextField.text       = [NSString stringWithFormat:@"%f",item.quantity.floatValue];
    self.unitTextField.text           = item.unit.name;
    self.unitTextField.selectObjectID = item.unit.objectID;
    self.shopTextField.text           = item.locationShop.locationAtShop;
    self.shopTextField.selectObjectID = item.locationShop.objectID;
    self.homeTextField.text           = item.locationHome.locationAtHome;
    self.homeTextField.selectObjectID = item.locationHome.objectID;
    self.photoImageView.image         = [UIImage imageWithData:item.photo.data];

    [self checkCameraOrPhotoAlbumAvailable];
}

- (void)hideKeyBoardWhenBackgroundIsTapped
{
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyBoard:)];
    tapGes.numberOfTapsRequired    = 1;
    [tapGes setCancelsTouchesInView:NO];
    [self.scrollerView addGestureRecognizer:tapGes];
}

- (void)hideKeyBoard:(id)sender
{
    [self.scrollerView endEditing:YES];
}

- (void)addKeyBoardNotification
{
    
    SEL keyBoardShow = @selector(keyBoardShow:);
    SEL keyBoardHide = @selector(keyBoardHide:);
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:keyBoardShow
                                                name:UIKeyboardWillShowNotification
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:keyBoardHide
                                                name:UIKeyboardWillHideNotification
                                              object:nil];
}

- (void)removeKeyBoardNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIKeyboardWillShowNotification
                                                 object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:UIKeyboardWillHideNotification
                                                 object:nil];
}

- (void)keyBoardShow:(NSNotification *)notification
{
    CGRect userInteractFrame = [[[notification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    userInteractFrame = [self.view convertRect:userInteractFrame fromView:nil];
    
    float keyBoardTop = userInteractFrame.origin.y;
    
    CGRect newScrollerViewFrame = CGRectMake(0, 0, self.view.bounds.size.width, keyBoardTop - self.view.bounds.origin.y);
    [self.scrollerView setFrame:newScrollerViewFrame];
    
    [self.scrollerView scrollRectToVisible:self.activeTextField.frame animated:YES];
}

- (void)keyBoardHide:(NSNotification *)notification
{
    CGRect defaultFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.scrollerView setFrame:defaultFrame];
    [self.scrollerView scrollRectToVisible:self.nameTextField.frame animated:YES];
}

- (void)ensureHomeLocationIsNotNil
{
    if (self.selectItemID) {
        AppDelegate *app    = [[UIApplication sharedApplication]delegate];
        CoreDataHelper *cdh = [app cdh];
        Item *item          = (Item *)[[cdh context]existingObjectWithID:self.selectItemID error:nil];
        if (!item.locationHome) {
            NSFetchRequest *homeFetch = [[cdh model]fetchRequestTemplateForName:@"unkonwHomeLocation"];
            NSArray *result           = [[cdh context]executeFetchRequest:homeFetch error:nil];
            if (result.count != 0) {
                item.locationHome = [result objectAtIndex:0];
            }else{
                LocationHome *locationHome = [NSEntityDescription insertNewObjectForEntityForName:@"LocationHome" inManagedObjectContext:cdh.context];
                NSError *error             = nil;
                if (![[cdh context]obtainPermanentIDsForObjects:@[locationHome] error:nil]) {
                    NSLog(@"could not find object %@",error);
                }
                locationHome.locationAtHome = @"..unknowLocation..";
                item.locationHome           = locationHome;
            }
        }
    }
}

- (void)ensureShopLocationIsNotNil
{
    if (self.selectItemID) {
        AppDelegate *app    = [[UIApplication sharedApplication]delegate];
        CoreDataHelper *cdh = [app cdh];
        Item *item          = (Item *)[[cdh context]existingObjectWithID:self.selectItemID error:nil];
        if (!item.locationShop) {
            NSFetchRequest *homeFetch = [[cdh model]fetchRequestTemplateForName:@"unknowShopLocation"];
            NSArray *result           = [[cdh context]executeFetchRequest:homeFetch error:nil];
            if (result.count != 0) {
                item.locationShop = [result objectAtIndex:0];
            }else{
                LocationShop *locationShop  = [NSEntityDescription insertNewObjectForEntityForName:@"LocationShop" inManagedObjectContext:cdh.context];
                NSError *error              = nil;
                if (![[cdh context]obtainPermanentIDsForObjects:@[locationShop] error:nil]) {
                    NSLog(@"could not find object %@",error);
                }
                locationShop.locationAtShop = @"..unknowLocation..";
                item.locationShop           = locationShop;
            }
        }
    }
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.nameTextField) {
        if ([textField.text isEqualToString:@"New Item"]) {
            textField.text = nil;
        }
    }else if (textField == self.unitTextField){
        [self.unitTextField fetch];
        [self.unitTextField.pickerView reloadAllComponents];
        [self.unitTextField selectDefaultRow];
    }else if (textField == self.shopTextField){
        [self.shopTextField fetch];
        [self.shopTextField.pickerView reloadAllComponents];
    }else if (textField == self.homeTextField){
        [self.homeTextField fetch];
        [self.homeTextField.pickerView reloadAllComponents];
    }
    
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    AppDelegate *app    = [UIApplication sharedApplication].delegate;
    CoreDataHelper *cdh = [app cdh];
    Item *item          = (Item *)[[cdh context]existingObjectWithID:self.selectItemID error:nil];
    if (textField == self.nameTextField) {
        if ([textField.text isEqualToString:@""]) {
            textField.text = @"New Item";
        }
        item.name = textField.text;
    }else if (textField == self.quantityTextField){
        item.quantity = [NSNumber numberWithFloat:[textField.text floatValue]];
    }else if (textField == self.unitTextField){
    
    }
    
    self.activeTextField = nil;
}

#pragma mark -WBPICKERDELEGATE

- (void)WBTextFieldConfirmAtManagerObjectID:(NSManagedObjectID *)managerObjectID textField:(CoreDateTF *)tf
{
    if (self.selectItemID) {
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate]cdh];
        Item *item          = (Item *)[[cdh context]existingObjectWithID:self.selectItemID error:nil];
        
        NSError *err;
        if (tf == self.unitTextField) {
            Unit *unit              = (Unit *)[[cdh context]existingObjectWithID:managerObjectID error:&err];
            item.unit               = unit;
            self.unitTextField.text = unit.name;
        }else if (tf == self.shopTextField){
            LocationShop *shop      = (LocationShop *)[[cdh context]existingObjectWithID:managerObjectID error:&err];
            item.locationShop       = shop;
            self.shopTextField.text = shop.locationAtShop;
        }else if (tf == self.homeTextField){
            LocationHome *home      = (LocationHome *)[[cdh context]existingObjectWithID:managerObjectID error:&err];
            item.locationHome       = home;
            self.homeTextField.text = home.locationAtHome;
        }
        
        [self refreshView];
        if (err) {
            NSLog(@"cannot find unit ,err %@",err);
        }
    }
}

- (void)WBTextFieldClearWithTextField:(CoreDateTF *)tf
{
    if (self.selectItemID) {
        CoreDataHelper *cdh = [(AppDelegate *)[[UIApplication sharedApplication]delegate]cdh];
        Item *item          = (Item *)[[cdh context]existingObjectWithID:self.selectItemID error:nil];
        if (tf == self.unitTextField) {
            item.unit               = nil;
            self.unitTextField.text = nil;
        }else if (tf == self.shopTextField){
            
            NSFetchRequest *unknowlocationRequest = [[cdh model] fetchRequestTemplateForName:@"unknowShopLocation"];
            NSArray *fetchResult = [[cdh context]executeFetchRequest:unknowlocationRequest error:nil];
            if ([fetchResult count] > 0) {
                LocationShop *unknowshopLocation = [fetchResult objectAtIndex:0];
                item.locationShop = unknowshopLocation;
                self.shopTextField.text = unknowshopLocation.locationAtShop;
            }
            
        }else if (tf == self.homeTextField){
            
            NSFetchRequest *unknowlocationRequest = [[cdh model] fetchRequestTemplateForName:@"unkonwHomeLocation"];
            NSArray *fetchResult = [[cdh context]executeFetchRequest:unknowlocationRequest error:nil];
            if ([fetchResult count] > 0) {
                LocationHome *unknowhomeLocation = [fetchResult objectAtIndex:0];
                item.locationHome = unknowhomeLocation;
                self.shopTextField.text = unknowhomeLocation.locationAtHome;
            }
            
        }
        
        [self refreshView];
    }
}

#pragma mark -TAKE PHOTO DELEGATE


- (BOOL)checkCameraOrPhotoAlbumAvailable
{
    BOOL cameraUseful     = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    BOOL photoAlbumUseful = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if (cameraUseful || photoAlbumUseful) {
        self.cameraBtn.enabled = YES;
    }else{
        self.cameraBtn.enabled = NO;
    }
    
    return cameraUseful || photoAlbumUseful;
}

- (IBAction)takePhoto:(id)sender {
    if ([self checkCameraOrPhotoAlbumAvailable]) {
        self.imagePickerCtl               = [[UIImagePickerController alloc]init];
        self.imagePickerCtl.delegate      = self;
        self.imagePickerCtl.allowsEditing = YES;

        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePickerCtl.sourceType = UIImagePickerControllerSourceTypeCamera;
        }else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
            self.imagePickerCtl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        [self.navigationController presentViewController:self.imagePickerCtl animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *photo            = [info valueForKey:UIImagePickerControllerEditedImage];

    CoreDataHelper *cdh       = [(AppDelegate *)[UIApplication sharedApplication].delegate cdh];
    Item *item                = (Item *)[[cdh context]existingObjectWithID:self.selectItemID error:nil];
    
    if (!item.photo) {
        ItemPhoto *newphoto = [NSEntityDescription insertNewObjectForEntityForName:@"ItemPhoto" inManagedObjectContext:cdh.context];
        [cdh.context obtainPermanentIDsForObjects:@[newphoto] error:nil];
        item.photo = newphoto;
    }
    item.photo.data           = UIImageJPEGRepresentation(photo, 0.5);
    
//    item.photoData = UIImageJPEGRepresentation(photo, 0.5);
    self.photoImageView.image = photo;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
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
