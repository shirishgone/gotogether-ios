//
//  GTCommentsViewController.m
//  goTogether
//
//  Created by shirish on 20/08/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTCommentsViewController.h"
#import "GTCommentCell.h"
#import "NSString+GTExtensions.h"
#import "GTRideDetailsParentViewController.h"

#define kDefaultCellHeight 60.0f

@interface GTCommentsViewController ()

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *commentBarView;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIButton *commentPostButton;
@property (nonatomic, strong) NSArray *comments;

- (IBAction)postButtonClicked:(id)sender;

@end

@implementation GTCommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPullToRefreshForTableView:self.tableView];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(fetchCommentsAndReload)
     name:kNotificaionType_comment
     object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(textFieldTextDidChange:)
     name:UITextFieldTextDidChangeNotification
     object:self.commentTextField];
    
    [self trackScreenName:@"Comments"];
    
    if (self.event !=nil) {
        [self fetchCommentsAndReload];
    }
}


- (void)fetchCommentsAndReload {
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)
    [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.netStatus != kNotReachable) {
        [self displayActivityIndicatorViewWithMessage:@"Loading messages..."];

        [Comment
         getCommentsWithEventId:_event.eventId
         sucess:^(NSArray *comments) {

             [self doneLoading];
             self.comments = [comments copy];
             if(comments.count > 0){
                 [self removeNoResultsLabel];
             }else{
                 [self handleNoComments];
             }
             [self.tableView reloadData];
         }failure:^(NSError *error) {
             [self doneLoading];
             [self displayFailureMessage:@"Loading failed."];
         }];
    }else{
        [self displayNoInternetMessage];
    }
}

- (void)handleNoComments {
    if (self.comments.count == 0) {
        if (self.commentTextField.editing == YES) {
            [self removeNoResultsLabel];
        }else{
            [self displayNoResultsLabelWithMessage:@"Send a message!"];
        }
    }
}

#pragma mark - table view datasource
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section{

    return [self.comments count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cell_resuableIdentifier = kCellIdentifier_comments;
    GTCommentCell *cell = (GTCommentCell *)
    [tableView dequeueReusableCellWithIdentifier:cell_resuableIdentifier
                                    forIndexPath:indexPath];
    Comment *comment = [_comments objectAtIndex:indexPath.row];
    [cell setTripComment:comment];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    Comment *comment = [_comments objectAtIndex:indexPath.row];
    CGFloat height = [GTCommentCell heightForCommentLabelForString:comment.commentString];
    return 40.0 + height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = [_comments objectAtIndex:indexPath.row];
    NSString *userId = comment.commentedUserId;

    GTRideDetailsParentViewController *rideDetailsParentViewController = (GTRideDetailsParentViewController *)[self parentViewController];
    [rideDetailsParentViewController pushToShowUserWithId:userId];
}


#pragma mark - text field delegates
- (void)textFieldTextDidChange:(NSNotification *)notification{
    
    if ([notification.object isKindOfClass:[UITextField class]]) {
    
        [self handleNoComments];
        UITextField *textField = notification.object;
        NSString *textFieldString = textField.text;
        textFieldString = [textFieldString stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
}

- (IBAction)postButtonClicked:(id)sender{
    
    NSString *commentString = self.commentTextField.text;
    if ([commentString length] == 0) {
        [self displayFailureMessage:@"Please add a message."];
        return;
    }
    
    [self.commentTextField setText:@"Sending message..."];
    [self.commentTextField resignFirstResponder];
    
    goTogetherAppDelegate *appDelegate = (goTogetherAppDelegate *)
    [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.netStatus != kNotReachable) {
        User *currentUser = [User currentUser];
        [Comment
         addComment:commentString
         eventId:_event.eventId
         userId:currentUser.userId
         sucess:^(id response) {
             
             [self.commentTextField setText:@"Sent successfully!"];
             [self performSelector:@selector(clearTextField) withObject:nil afterDelay:1.0];
             [self performSelector:@selector(fetchCommentsAndReload) withObject:nil afterDelay:2.0];
         } failure:^(NSError *error) {

             TALog(@"response: %@",error.description);
             [self.commentTextField setText:@"Error!"];
             [self performSelector:@selector(clearTextField) withObject:nil afterDelay:kAlertDisplayTime];
         }];
        
    }else{

        [self displayNoInternetMessage];
    }
}

- (void)clearTextField{
    [self.commentTextField setText:@""];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self handleNoComments];
    [self setFramesWithValue:-kKeyboardHeight];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self handleNoComments];
    [self setFramesWithValue:kKeyboardHeight];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)setFramesWithValue:(float)value{
    
    CGRect commentBarFrame =  self.commentBarView.frame;
    CGRect tableFrame = self.tableView.frame;
    
    [UIView beginAnimations:@"Animation" context:nil];
    [self.commentBarView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.commentBarView setFrame:CGRectMake(commentBarFrame.origin.x,
                                             commentBarFrame.origin.y + value,
                                             commentBarFrame.size.width,
                                             commentBarFrame.size.height)];
    
    [self.tableView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self.tableView setFrame:CGRectMake(tableFrame.origin.x,
                                        tableFrame.origin.y,
                                        tableFrame.size.width,
                                        tableFrame.size.height + value)];
    
    [UIView commitAnimations];
    
}

#pragma mark - PullToRefresh
- (void)refresh:(id)sender{
    [self fetchCommentsAndReload];
}

- (void)doneLoading{
    [self hideStatusMessage];
    [self stopRefreshing];
}

@end
