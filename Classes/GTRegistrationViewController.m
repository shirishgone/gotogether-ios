//
//  GTRegistrationViewController.m
//  goTogether
//
//  Created by shirish on 19/03/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "GTRegistrationViewController.h"
#import "GTPhoneNumberVerificationController.h"
#import "GTPrivacyPolicyViewController.h"
#import "goTogetherAppDelegate.h"
#import "GTValidations.h"
#import "User.h"
#import "NSManagedObject+MagicalRecord.h"
#import "UIImage+TAExtensions.h"
#import "GTValidations.h"
#import "GTAWSManager.h"

#import "GCPlaceholderTextView.h"
#import "SIAlertView.h"
#import "UIImageView+GTExtensions.h"

@interface GTRegistrationViewController ()
<UITextFieldDelegate,
UIImagePickerControllerDelegate,
UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UISegmentedControl *genderSelectionControl;
@property (strong, nonatomic) IBOutlet UITextField *userNameField;
@property (nonatomic, strong) IBOutlet UITextField *emailField;

@property (strong, nonatomic) IBOutlet UIButton *profileImageButton;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (strong, nonatomic) NSString *savedProfilePictureString;

- (IBAction)signupButtonTouched:(id)sender;
- (IBAction)imagePicButtonTouched:(id)sender;
- (IBAction)termsOfServiceButtonTouched:(id)sender;
@end

@implementation GTRegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:kColorGlobalBackground];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self trackScreenName:@"Registration"];
}

- (void)didreceivememorywarning {
    self.profileImageView.image = nil;
    [super didReceiveMemoryWarning];
}

#pragma mark - setup methods

- (void)setPicture:(UIImage *)image{
    
    [self.profileImageView setImage:image];
    [self.profileImageView scaleProfilePic];
}

#pragma mark - imagePicker methods
- (IBAction)imagePicButtonTouched:(id)sender{
    UIActionSheet *popupQuery = [[UIActionSheet alloc]
                                 initWithTitle:nil
                                 delegate:self
                                 cancelButtonTitle:@"Cancel"
                                 destructiveButtonTitle:nil
                                 otherButtonTitles:@"Take a Photo", @"Upload from library", nil];
    
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    _imagePickerController.allowsEditing = YES;
    _imagePickerController.videoQuality = UIImagePickerControllerQualityTypeLow;
    
    if (buttonIndex == 0)
    {
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:_imagePickerController animated:YES completion:nil];
    }
    else if (buttonIndex == 1)
    {
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO)
            _imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:_imagePickerController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [picker dismissViewControllerAnimated:NO completion:^{
        UIImage *image = [[info objectForKey:UIImagePickerControllerOriginalImage] fixOrientation];
        [self setPicture:image];
    }];
    
}

#pragma mark - action handlers
- (IBAction)termsOfServiceButtonTouched:(id)sender {
    [self presentPrivacyPolicyController];
}

- (void)cancelButtonTouched:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)signupButtonTouched:(id)sender{

    if (self.profileImageView.image == nil) {
        [self displayFailureMessage:@"Please set your profile picture."];
        return;
    }
    if ([GTValidations validateUser:self.userNameField.text] == NO) {
        [self displayFailureMessage:@"Please enter a valid name."];
        return;
    }
    if ([GTValidations validateEmail:self.emailField.text] == NO) {
        [self displayFailureMessage:@"Please enter a valid email address."];
        return;
    }
    if (self.passwordField.text.length <=0) {
        [self displayFailureMessage:@"Please set a password for your account on gotogether."];
        return;
    }
    if ([GTValidations validatePassword:self.passwordField.text] == NO) {
        [self displayFailureMessage:@"A valid password must be more than 6 characters."];
        return;
    }

    [self resignFirstResponders];
    [self registerUser];
}

#pragma mark - GoTogether API Call
- (void)registerUser {
    User *user =  [User MR_createInContext:[NSManagedObjectContext defaultContext]];
    [user setEmail:self.emailField.text];
    if (_genderSelectionControl.selectedSegmentIndex == 0) {
        [user setGender:@"Male"];
    }else{
        [user setGender:@"Female"];
    }

    [user setPassword:self.passwordField.text];
    [user setUserId:self.emailField.text];
    [user setName:self.userNameField.text];
    
    // Register to Gotogether server
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.netStatus != kNotReachable) {
        [self displayActivityIndicatorViewWithMessage:@"Signing up..."];
        [User
         registerUser:user
         sucess:^(id response) {

             // Save picture to amazon s3
             [[GTAWSManager sharedInstance]
              uploadImageToServer:self.profileImageView.image
              withName:user.userId];
             
             [self.navigationController popViewControllerAnimated:YES];
             
             SIAlertView *alert = [[SIAlertView alloc] initWithTitle:nil andMessage:response];
             [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
             [alert show];
             
         } failure:^(NSError *error) {
             [[GTAnalyticsManager sharedInstance] logRegistrationFailed];
             NSString *errorDescription = [error.userInfo valueForKey:@"errorDescription"];
             if (errorDescription == nil) {
                 errorDescription = @"Registration failed!";
             }
             [self displayFailureMessage:errorDescription];
             TALog(@"error: %@",error);
         }];
        
    }else{
        [self displayNoInternetMessage];
    }
}

#pragma mark - present privacy controller

- (void)presentPrivacyPolicyController{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:kLoginStoryBoardIdentifier
                                                         bundle:[NSBundle mainBundle]];
    GTPrivacyPolicyViewController *privacyPolicyViewController =
    [storyBoard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_privacyPolicy];
    [self presentViewController:privacyPolicyViewController animated:YES completion:nil];
}

#pragma mark - TextView and TextField delegates
- (void)resignFirstResponders {
    [self.passwordField resignFirstResponder];
    [self.userNameField resignFirstResponder];
    [self.emailField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == _userNameField){
        [self.emailField becomeFirstResponder];
    }else if (textField == _emailField){
        [self.passwordField becomeFirstResponder];
    }else if (textField == _passwordField){
        [self.passwordField resignFirstResponder];
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,
                                         self.tableView.frame.origin.y,
                                         self.tableView.frame.size.width,
                                         self.tableView.frame.size.height - kResizeHeight)];

    [self scrollOffsetForTextField:textField toTop:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,
                                        self.tableView.frame.origin.y,
                                        self.tableView.frame.size.width,
                                        self.tableView.frame.size.height + kResizeHeight)];
}

- (void)scrollOffsetForTextField:(UITextField *)textField toTop:(BOOL)toTop{
    if (toTop) {
        [UIView animateWithDuration:kTableScrollAnimationDuration animations:^{
            [self.tableView setContentOffset:CGPointMake(0.0, 0.0)];
        }];
    }else{
        [UIView animateWithDuration:kTableScrollAnimationDuration animations:^{
            if (textField == self.userNameField) {
                [self.tableView setContentOffset:CGPointMake(0.0, 60.0)];
            }else if (textField == self.emailField){
                [self.tableView setContentOffset:CGPointMake(0.0, 120.0)];
            }else if (textField == self.passwordField){
                [self.tableView setContentOffset:CGPointMake(0.0, 140.0)];
            }
        }];
    }
}

@end
