//
//  GTHomeViewController.m
//  goTogether
//
//  Created by shirish on 03/11/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTHomeViewController.h"

const CGFloat kYPosition = 80.0;
const CGFloat kButton_Height = 20.0;
const CGFloat kButton_Width = 50.0;


@interface GTHomeViewController ()
@property (nonatomic, strong) IBOutlet UILabel *lookingForLabel;
@property (nonatomic, strong) IBOutlet UIButton *passengerButton;
@property (nonatomic, strong) IBOutlet UIButton *rideButton;

@end

@implementation GTHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)passengerButtonTouched:(id)sender{
    [self animateButtons];
}

- (IBAction)rideButtonTouched:(id)sender{
    [self animateButtons];    
}

- (void)animateButtons{

    [UIView
     animateWithDuration:1.0
     animations:^{
         
         CGSize labelSize =  _lookingForLabel.frame.size;
         [_lookingForLabel setFrame:CGRectMake(10,
                                               kYPosition,
                                               labelSize.width,
                                               labelSize.height)];
         
         [_passengerButton setFrame:CGRectMake(_lookingForLabel.frame.origin.x + labelSize.width + 10.0,
                                               kYPosition,
                                               kButton_Width,
                                               kButton_Height)];
         
         [_rideButton setFrame:CGRectMake(_passengerButton.frame.origin.x + _passengerButton.frame.size.width,
                                          kYPosition,
                                          kButton_Width,
                                          kButton_Height)];
                         
     }];
}
@end
