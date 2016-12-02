//
//  GTAddVehicleViewController.m
//  goTogether
//
//  Created by Shirish on 1/5/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTAddVehicleViewController.h"
#import "UIToolbar+GTExtensions.h"

#define kPickerTag_MakeModel 100


@interface GTAddVehicleViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, weak) IBOutlet UITextField *vehicleNumber;
@property (nonatomic, weak) IBOutlet UILabel *make;
@property (nonatomic, weak) IBOutlet UILabel *model;

@property (nonatomic, strong) NSArray *makeArray;
@property (nonatomic, strong) NSDictionary *carsDict;

@property (nonatomic, strong) NSString *selectedMake;
@property (nonatomic, strong) NSString *selectedModel;

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, assign) BOOL isEditMode;
@end

@implementation GTAddVehicleViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    [self loadVehicleData];
    [self loadVehicleDetails:self.vehicle];
    [self addCancelButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self trackScreenName:@"AddVehicle"];
}

- (void)addCancelButton {
    if (self.isEditMode == NO) {
        if (self.navigationItem.leftBarButtonItem == nil) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelTouched:)];
        }
    }
}

- (void)setVehicle:(Vehicle *)vehicle{
    _vehicle = vehicle;
    self.isEditMode = YES;
}

- (void)loadVehicleData {
    [Vehicle getVehiclesWithSucess:^(NSDictionary *vehicles) {
        self.makeArray = [vehicles allKeys];
        self.carsDict = vehicles;
    } failure:^(NSError *error) {
        [self displayFailureMessage:@"Fetching vehicles failed."];
    }];
}

- (BOOL)isAllTheFieldsFilled {

    if(self.vehicleNumber.text == nil || [self.vehicleNumber.text length] < 8){
        return NO;
    }
    if(self.make.text ==nil || [self.make.text length] < 2){
        return NO;
    }
    if(self.model.text ==nil || [self.model.text length] < 2){
        return NO;
    }
    return YES;
}

- (void)loadVehicleDetails:(Vehicle *)vehicle {
    if (_vehicle !=nil) {
        [self.make setText:vehicle.make];
        [self.model setText:vehicle.model];
        [self.vehicleNumber setText:vehicle.vehicleNumber];
    }
}
#pragma mark - uitextfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self.vehicleNumber resignFirstResponder];
    [self addPickerViewWithTag:kPickerTag_MakeModel];
}

#pragma mark - 

- (void)addPickerViewWithTag:(int)tag {
    // Remove if already added
    if (self.pickerView != nil) {
        return;
    }

    float pickerHeight = 200;
    CGRect viewFrame = [self.view frame];
    
    self.toolbar =
    [UIToolbar GTToolBarWithDoneButtonWithDelegate:self andSelector:@selector(pickerDoneClicked:)];

    CGRect toolBarFrame = self.toolbar.frame;
    toolBarFrame =  CGRectMake(0, viewFrame.size.height - pickerHeight - 44.0, toolBarFrame.size.width, toolBarFrame.size.height);
    [self.toolbar setFrame:toolBarFrame];

    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, viewFrame.size.height - pickerHeight, viewFrame.size.width, pickerHeight)];
    [_pickerView setBackgroundColor:[UIColor whiteColor]];
    [_pickerView setDelegate:self];
    [_pickerView setDataSource:self];
    _pickerView.tag = tag;
    [_pickerView showsSelectionIndicator];
    [self.view addSubview:_pickerView];
    [self.view addSubview:_toolbar];

}


- (void)pickerDoneClicked:(id)sender{

    [self.make setText:self.selectedMake];
    [self.model setText:self.selectedModel];

    [self.toolbar removeFromSuperview];
    [self.pickerView removeFromSuperview];
    self.toolbar = nil;
    self.pickerView = nil;
}

#pragma mark - action sheet delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

#pragma mark - picker delegates

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (component == 0) {
        return [self.makeArray count];
    }else{
        int selectedMakeIndex = [self.pickerView selectedRowInComponent:0];
        NSString *make = [self.makeArray objectAtIndex:selectedMakeIndex];
        NSArray *modelsArray = [self.carsDict valueForKey:make];
        return [modelsArray count];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (component == 0) {
        return [self.makeArray objectAtIndex:row];
    }else{
        
        int selectedMakeIndex = [self.pickerView selectedRowInComponent:0];
        NSString *make = [self.makeArray objectAtIndex:selectedMakeIndex];
        NSArray *modelsArray = [self.carsDict valueForKey:make];
        return [modelsArray objectAtIndex:row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component== 0) {
        self.selectedMake = [self.makeArray objectAtIndex:row];
        [self.pickerView reloadAllComponents];
        
    }else if (component == 1){
        NSArray *modelsArray = [self.carsDict valueForKey:self.selectedMake];
        self.selectedModel = [modelsArray objectAtIndex:row];
    }
}

#pragma mark - action handlers
- (void)cancelTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveTouched:(id)sender {
    if ([self isAllTheFieldsFilled]) {
        [self performApiCall];
    }else{
        [self displayFailureMessage:@"Please fill all details."];
    }
}

- (void)performApiCall {
    if (self.appDelegate.netStatus != kNotReachable) {
        [self displayActivityIndicatorViewWithMessage:@"Saving vehicle details..."];
        
        [Vehicle
         addVehicleWithNumber:self.vehicleNumber.text
         make:self.make.text
         model:self.model.text
         color:@""
         sucess:^(id response) {

             if (self.isEditMode) {
                 if ([self.delegate respondsToSelector:@selector(editVehicleSuccessful)]) {
                     [self.delegate editVehicleSuccessful];
                 }
             }else {
                 if ([self.delegate respondsToSelector:@selector(vehicleDetailsAddedSuccessfully)]) {
                     [self.delegate vehicleDetailsAddedSuccessfully];
                 }
             }
             
             [self displaySucessMessage:@"Vehicle details saved!"];
             if (self.isEditMode) {
                 [self.navigationController popViewControllerAnimated:YES];
             }else{
                 [self dismissViewControllerAnimated:YES completion:nil];
             }
         } failure:^(NSError *error) {
             [self displayFailureMessage:@"Saving failed. Please try again!"];
         }];
    }else{
        [self displayNoInternetMessage];
    }
}

@end
