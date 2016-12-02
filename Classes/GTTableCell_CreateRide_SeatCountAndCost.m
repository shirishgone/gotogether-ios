//
//  GTCreateRideTableCell_SeatCountAndCost.m
//  goTogether
//
//  Created by shirish on 09/04/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import "GTTableCell_CreateRide_SeatCountAndCost.h"

@interface GTTableCell_CreateRide_SeatCountAndCost ()
#pragma mark - Cost IBOutlets
@property (nonatomic, strong) IBOutlet UILabel *costLabel;
@property (nonatomic, strong) IBOutlet UIImageView *costIconImageView;
@property (nonatomic, strong) IBOutlet UITextField *costTextField;
#pragma mark - SeatCount IBOutlets
@property (nonatomic, strong) IBOutlet UILabel *seatCountLabel;
@property (nonatomic, strong) IBOutlet UIButton *decrementButton;
@property (nonatomic, strong) IBOutlet UIButton *incrementButton;
@property (nonatomic, strong) IBOutlet UILabel *seatCountValueLabel;

- (IBAction)decrementButtonTouched:(id)sender;
- (IBAction)incrementButtonTouched:(id)sender;
@end

@implementation GTTableCell_CreateRide_SeatCountAndCost

- (void)awakeFromNib{
    [self setupDoneButtonBarForPriceKeyboard];
    [self updateView];
}

- (IBAction)decrementButtonTouched:(id)sender{
    if (_seatCount > 1) {
        _seatCount--;
        [self updateView];
        [self delegateSeatCount];
    }
}
- (IBAction)incrementButtonTouched:(id)sender{
    if (_seatCount < 5) {
        _seatCount++;
        [self updateView];
        [self delegateSeatCount];
    }
}

- (void)setCost:(double)cost{
    _cost = cost;
    [_costTextField setText:[NSString stringWithFormat:@"%.0f",cost]];
}

- (void)setSeatCount:(NSInteger)seatCount{
    _seatCount = seatCount;
    [self updateView];
}

- (void)updateView{
    [_seatCountValueLabel setText:[NSString stringWithFormat:@"%d",_seatCount]];
}

- (void)setupDoneButtonBarForPriceKeyboard{
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                      target:self
                                      action:@selector(doneWithNumberPad)
                                      ];
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           doneBarButton,
                           nil];
    [numberToolbar sizeToFit];
    _costTextField.inputAccessoryView = numberToolbar;
}

- (void)doneWithNumberPad{
    [_costTextField resignFirstResponder];
    NSString *costString = _costTextField.text;
    self.cost = [costString doubleValue];
    [self delegateSeatCost];
}

#pragma mark - delegates
- (void)delegateSeatCost{
    if (_delegate !=nil && [_delegate respondsToSelector:@selector(priceSelected:)]) {
        [_delegate priceSelected:self.cost];
    }
}

- (void)delegateSeatCount{
    if (_delegate !=nil && [_delegate respondsToSelector:@selector(numberOfSeatsSelected:)]) {
        [_delegate numberOfSeatsSelected:self.seatCount];
    }    
}
@end
