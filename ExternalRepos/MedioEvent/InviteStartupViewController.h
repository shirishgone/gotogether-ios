//
//  InviteStartupViewController.h
//  MedioEvent
//
//  Created by Toly Pochkin on 4/6/13.
//
//

#import <UIKit/UIKit.h>
#import "InviteModels.h"
#import "MEInviteServiceConfig.h"


@class InviteStartupViewController;


@protocol InviteStartupViewControllerDelegate <NSObject>

@required
- (void)willCloseInviteStartupViewController:(InviteStartupViewController*)vc;
- (void)didCloseInviteStartupViewController:(InviteStartupViewController*)vc;

@end


@interface InviteStartupViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<InviteStartupViewControllerDelegate> delegate;
@property (nonatomic, strong) MEInviteServiceConfig* inviteServiceConfig;
@property (nonatomic, strong) SyncResponse* syncResponse;
- (void)resync;

@end
