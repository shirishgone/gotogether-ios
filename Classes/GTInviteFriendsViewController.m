//
//  GTInviteFriendsViewController.m
//  goTogether
//
//  Created by shirish on 07/04/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTInviteFriendsViewController.h"
#include <AddressBook/ABPerson.h>
#include <AddressBook/ABMultiValue.h>
#import "User.h"
#import "goTogetherAppDelegate.h"
#import "TAFacebookManager.h"
#import "GTInviteTableViewCell.h"
#import "GTInviteContact.h"
#import "GTValidations.h"

#define kRowHeight 60.0

@interface GTInviteFriendsViewController () <GTInviteTableViewCellDelegate>

@property (nonatomic, strong) NSArray *fullContacts;
@property (nonatomic, strong) NSMutableArray *searchContacts;

@end

@implementation GTInviteFriendsViewController

- (void)awakeFromNib {
    self.fullContacts = [NSArray array];
    self.searchContacts = [NSMutableArray array];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupDoneButton];
    [self fetchContacts];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self trackScreenName:@"InviteFriends"];
}

#pragma mark - Setup buttons and handlers

- (void)setupDoneButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTouched:)];
}

- (void)doneButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Fetch Contacts

- (void)fetchContacts {

    NSMutableArray *result = [[NSMutableArray alloc] init];
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL){
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else{
        accessGranted = YES;
    }
    if (accessGranted){
        // If the app is authorized to access the first time then add the contact
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        
        for (int i = 0; i < numberOfPeople; i++){
            CFStringRef phone;
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            CFStringRef firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
            CFStringRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
            NSString *userName = @"NoName";
            
            userName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
            userName = [userName stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
            
            ABMutableMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            CFIndex phoneNumberCount = ABMultiValueGetCount( phoneNumbers );
            
            phone = nil;
            
            for ( CFIndex ind = 0; ind<phoneNumberCount; ind++ ){
                CFStringRef phoneNumberLabel = ABMultiValueCopyLabelAtIndex( phoneNumbers, ind);
                CFStringRef phoneNumberValue = ABMultiValueCopyValueAtIndex( phoneNumbers, ind);
                
                // converts "_$!<Work>!$_" to "work" and "_$!<Mobile>!$_" to "mobile"
                // Find the ones you want here
                if (phoneNumberLabel != nil){
                    NSStringCompareOptions  compareOptions = NSCaseInsensitiveSearch;
                    if(CFStringCompare(phoneNumberLabel, CFSTR("mobile"),compareOptions)){
                        phone = phoneNumberValue;
                    }
                    phone = phoneNumberValue;
                    
                    NSStringCompareOptions  compareOptionss = NSCaseInsensitiveSearch;
                    if(!CFStringCompare(phone, CFSTR("1-800-MY-APPLE"),compareOptionss)){
                        continue;
                    }
                    GTInviteContact *contact = [[GTInviteContact alloc] init];

                    contact.phoneNumber = (__bridge NSString *)phone ;
                    contact.name = userName;
                    [result addObject:contact];
                }
            }
        }

        //sort array
        NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                    ascending:YES];
        NSArray * sortedArray = [result sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
        
        self.fullContacts = [sortedArray copy];
        [self.tableView reloadData];

    }else {
        [self showSettingsAlert];
    }
}

- (void)showSettingsAlert {

    NSString *messageString = @"Please give the permission to access contacts.";
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil
                                                     andMessage:messageString];
    [alertView addButtonWithTitle:@"Open" type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                          }];
        [self dismissViewControllerAnimated:YES completion:nil];

    [alertView addButtonWithTitle:@"Later" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertView setTransitionStyle:SIAlertViewTransitionStyleDropDown];
    [alertView setBackgroundStyle:SIAlertViewBackgroundStyleSolid];
    [alertView show];
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView){
        return [self.searchContacts count];
    }else{
        return [self.fullContacts count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    GTInviteTableViewCell *cell = nil;
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier_invite];
    cell.delegate = self;
    GTInviteContact *contact = nil;

    if (tableView == self.searchDisplayController.searchResultsTableView){
        contact = [self.searchContacts objectAtIndex:indexPath.row];
    }else{
        contact = [self.fullContacts objectAtIndex:indexPath.row];
    }

    [cell setContactDict:contact];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)inviteContact:(GTInviteContact *)contact {
    NSMutableString *phoneNumberString = [NSMutableString stringWithString:contact.phoneNumber];
    
    phoneNumberString = [[[phoneNumberString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""] mutableCopy];
    
    NSInteger length = [phoneNumberString length];
    if (length > 10) {
        phoneNumberString = [[phoneNumberString substringWithRange:NSMakeRange(length - 10, 10)] mutableCopy];
    }
    
    if ([GTValidations doesPhoneNumberContainCountryCode:phoneNumberString] == NO) {
        phoneNumberString = [[GTValidations makeInternationalPhoneNumber:phoneNumberString]
                             mutableCopy];
    }else{
        phoneNumberString = [[NSString stringWithFormat:@"+%@",phoneNumberString] mutableCopy];
    }

    TALog(@"Phone number: %@",phoneNumberString);
    
    [User
     inviteContactWithPhoneNumber:phoneNumberString
     sucess:^(NSString *sucessMessage) {
         TALog(@"message: %@",sucessMessage);
     } failure:^(NSError *error) {
         TALog(@"error: %@",error);
    }];
}

#pragma mark - search display 

- (void)searchTableListWithString:(NSString *)searchString {

    [self.searchContacts removeAllObjects];
    
    for (GTInviteContact *contact in self.fullContacts) {

        NSComparisonResult result = [contact.name compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        if (result == NSOrderedSame) {
            [self.searchContacts addObject:contact];
        }
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if([searchText length] != 0) {
        [self searchTableListWithString:searchText];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
 shouldReloadTableForSearchString:(NSString *)searchString {

    return YES;
}

@end
