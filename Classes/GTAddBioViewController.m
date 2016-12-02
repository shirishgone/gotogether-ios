//
//  GTAddBioViewController.m
//  goTogether
//
//  Created by shirish gone on 12/07/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTAddBioViewController.h"

@interface GTAddBioViewController ()

@property (nonatomic, strong) IBOutlet UITextView *bioTextField;

@end


@implementation GTAddBioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBorderToBioTextField];
    [self setupSaveButton];
    [self initialiseBioField];
}


#pragma mark - TextView init

- (void)initialiseBioField {
    if (self.bioString !=nil) {
        [self.bioTextField setText:self.bioString];
    }else {
        [self.bioTextField setText:@""];
    }
}

- (void)addBorderToBioTextField {
    [self.bioTextField.layer setBorderWidth:1.0];
    [self.bioTextField.layer setCornerRadius:5.0];
    [self.bioTextField.layer setBorderColor:[kColorPalette_grayColor CGColor]];
}

#pragma mark - text view delegates

- (BOOL)isAcceptableTextLength:(NSUInteger)length {
    return length <= 80;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
    return [self isAcceptableTextLength:textView.text.length + string.length - range.length];
}

#pragma mark - Navigation Buttons

- (void)setupSaveButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonTouched:)];
}

- (void)saveButtonTouched:(id)sender {
    if ([_delegate respondsToSelector:@selector(saveUserBio:)]) {
        [_delegate saveUserBio:self.bioTextField.text];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
