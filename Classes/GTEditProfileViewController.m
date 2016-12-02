//
//  GTEditProfileViewController.m
//  goTogether
//
//  Created by shirish on 25/12/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTEditProfileViewController.h"
#import "UIImage+TAExtensions.h"
#import "GTAWSManager.h"
#import "GTValidations.h"
#import "UIImageView+GTExtensions.h"
#import "GTAddVehicleViewController.h"
#import "GTPhoneNumberVerificationController.h"
#import "GTAddBioViewController.h"
#import "TADateTimePicker.h"

@interface GTEditProfileViewController () <GTAddBioViewControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, GTAddVehicleDelegate>
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) IBOutlet UIImageView *profilePictureView;

@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UISegmentedControl *genderControl;
@property (nonatomic, strong) IBOutlet UILabel *bioLabel;
@property (nonatomic, strong) IBOutlet UILabel *phoneNumberLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateOfBirthLabel;
@property (nonatomic, copy) UIImage *updatedImage;
@property (nonatomic, strong) TADateTimePicker *datePicker;

@property (strong, nonatomic) User *user;

- (IBAction)genderControlValueChanged:(id)sender;
- (IBAction)profilePictureChangeButtonTouched:(id)sender;
- (IBAction)cancelButtonTouched:(id)sender;
- (IBAction)saveButtonTouched:(id)sender;

@end

@implementation GTEditProfileViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.tableView setBackgroundColor:kColorGlobalBackground];
    self.user = [User currentUser];
    [self reloadUserDetails];
    [self initialiseDatePicker];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self trackScreenName:@"EditProfile"];
}

- (void)initialiseDatePicker {
    if (_datePicker == nil) {

        CGRect datePickerRect = CGRectMake(0,
                                           self.view.frame.size.height - kDatePickerHeight,
                                           self.view.frame.size.width,
                                           kDatePickerHeight);
        _datePicker = [[TADateTimePicker alloc]
                       initForDateOfBirthWithFrame:datePickerRect];
        
        [_datePicker setMode:UIDatePickerModeDate];
        [_datePicker addTargetForDoneButton:self action:@selector(datePickerDoneButtonTapped:)];
    }
}
- (void)reloadUserDetails{
    [self.nameTextField setText:self.user.name];
    if ([self.user.gender isEqualToString:@"male"]) {
        [self.genderControl setSelectedSegmentIndex:0];
    }else {
        [self.genderControl setSelectedSegmentIndex:1];
    }

    if (self.user.profileDescription != nil) {
        [self.bioLabel setText:self.user.profileDescription];
    }else{
        [self.bioLabel setText:@"Unavailable"];
    }
    
    if (self.user.mobile != nil) {
        [self.phoneNumberLabel setText:self.user.mobile];
    }else{
        [self.phoneNumberLabel setText:@"Unavailable"];
    }
    
    // Set User Picture
    if ([UIImage isImageAvailableInCacheForUserId:self.user.userId]) {
        UIImage *cachedImage = [UIImage cachedImageforUserId:self.user.userId];
        [self setPicture:cachedImage];
    }else {
        if ([UIImage isAvailableLocallyForUserId:self.user.userId]) {
            NSString *imageFilePath = [UIImage filePathForUserId:self.user.userId];
            UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
            [self setPicture:image];
            
            [UIImage updateImageForUserId:self.user.userId
                                  success:^(UIImage *image) {
                                      [self setPicture:image];
                                  } failure:^(NSError *error) {
                                  }];
        }
    }
}

#pragma mark - table view delegates

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:kStoryBoardIdentifier
                                                         bundle:[NSBundle mainBundle]];
    if (indexPath.row == 2) {
        GTAddBioViewController *addBioViewController =
        [storyBoard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_addBio];
        
        addBioViewController.delegate = self;
        addBioViewController.bioString = self.user.profileDescription;
        [self.navigationController pushViewController:addBioViewController
                                             animated:YES];
        
    }else if (indexPath.row == 3) {
        GTPhoneNumberVerificationController *phoneNumberVerificationController =
        [storyBoard instantiateViewControllerWithIdentifier:kViewControllerIdentifier_phoneNumberVerify];
        [self.navigationController pushViewController:phoneNumberVerificationController
                                             animated:YES];
        
    }else if (indexPath.row == 4) {
        [self showDatePicker];
    }
}

#pragma mark - action handlers

- (IBAction)genderControlValueChanged:(id)sender {
    if (self.genderControl.selectedSegmentIndex == 0) {
        self.user.gender = @"Male";
    }else {
        self.user.gender = @"Female";
    }
}

- (IBAction)profilePictureChangeButtonTouched:(id)sender{
    UIActionSheet *optionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Take a photo", @"Upload from library", nil];
    optionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    self.imagePickerController = [[UIImagePickerController alloc] init];
    [optionSheet showInView:self.view];

}

- (IBAction)cancelButtonTouched:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonTouched:(id)sender{
    if ([self validateDetails] == NO) {
        return;
    }
    self.user.name = self.nameTextField.text;
    
    [self displayActivityIndicatorViewWithMessage:@"Updating details..."];
    [User updateUser:self.user
              sucess:^(id response) {
                  [self displaySucessMessage:@"Successfully updated!"];

                  // IMAGE Update
                  if (self.updatedImage) {
                      [UIImage saveImage:self.updatedImage withName:self.user.userId];
                      [self updatePictureOnAmazon];
                  }
                  
                  if ([self.delegate respondsToSelector:@selector(editProfileSucceeded)]) {
                      [self.delegate editProfileSucceeded];
                  }
                  
                  [self dismissViewControllerAnimated:YES completion:nil];
                  
              } failure:^(NSError *error) {
                  [self displayFailureMessage:@"Updated failed"];
              }];
    
}

- (void)updatePictureOnAmazon {
    if (self.updatedImage !=nil) {
        [[GTAWSManager sharedInstance]
         uploadImageToServer:self.updatedImage
         withName:self.user.userId];
    }
}

- (BOOL)validateDetails {
    if ([GTValidations validateUser:self.nameTextField.text] == NO) {
        [self displayFailureMessage:@"Please enter a valid Name."];
        return NO;
    }
    return YES;
}

#pragma mark - add vehicle delegate

- (void)editVehicleSuccessful {
    [self reloadUserDetails];
}

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        _imagePickerController = [self imagePickerController];
        
        [self presentViewController:_imagePickerController animated:YES completion:nil];
        
    }else if (buttonIndex == 1){
        _imagePickerController = [self imagePickerController];
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO)
            _imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:_imagePickerController animated:YES completion:nil];
    }else{
        [actionSheet dismissWithClickedButtonIndex:2 animated:YES];
    }
}

#pragma  mark - UIImage Picker Delegates

- (UIImagePickerController *)imagePickerController {
    self.imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    _imagePickerController.allowsEditing = YES;
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePickerController.videoQuality = UIImagePickerControllerQualityTypeLow;
    return _imagePickerController;
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSData *imageData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage],1);
    UIImage *image = [[UIImage imageWithData:imageData scale:1.0] fixOrientation];
    [self setPicture:image];
    self.updatedImage = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)setPicture:(UIImage *)image {
    [self.profilePictureView setImage:image];
    [self.profilePictureView scaleProfilePic];
}

#pragma mark - add bio delegate

- (void)saveUserBio:(NSString *)bioString {
    self.user.profileDescription = bioString;
    [self.bioLabel setText:bioString];
}

#pragma mark - data picker methods

- (void)showDatePicker {
    [self removePicker];
    
    [self.datePicker setFrame:CGRectMake(0,
                                         self.view.frame.size.height - 260,
                                         self.view.frame.size.width,
                                         260)];
    [self.view addSubview:self.datePicker];
}

- (void)removePicker {
    [self.datePicker removeFromSuperview];
}

- (void)datePickerDoneButtonTapped:(id)date{
    [self setDate:date];
    [self removePicker];
}

- (void)setDate:(id)date {
    self.user.dateOfBirth = date;
    NSString *dateString = [NSDate display_dateOfBirthStringFromDate:date];
    [_dateOfBirthLabel setText:dateString];
}

#pragma mark - TextView and TextField delegates

- (void)resignFirstResponders {
    [self.nameTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,
                                        self.tableView.frame.origin.y,
                                        self.tableView.frame.size.width,
                                        self.tableView.frame.size.height - kResizeHeight)];
    
    [self scrollOffsetForTextField:textField toTop:NO];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.tableView setFrame:CGRectMake(self.tableView.frame.origin.x,
                                        self.tableView.frame.origin.y,
                                        self.tableView.frame.size.width,
                                        self.tableView.frame.size.height + kResizeHeight)];
}

- (void)scrollOffsetForTextField:(UITextField *)textField toTop:(BOOL)toTop {
    if (toTop) {
        [UIView animateWithDuration:kTableScrollAnimationDuration animations:^{
            [self.tableView setContentOffset:CGPointMake(0.0, 0.0)];
        }];
    }else{
        [UIView animateWithDuration:kTableScrollAnimationDuration animations:^{
            if (textField == self.nameTextField) {
                [self.tableView setContentOffset:CGPointMake(0.0, 60.0)];
            }
        }];
    }
}

@end
