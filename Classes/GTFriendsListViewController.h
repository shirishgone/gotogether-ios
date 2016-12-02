//
//  GTFriendsListViewController.h
//  goTogether
//
//  Created by shirish on 22/03/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

typedef enum {
    GTFriendsListViewModeNormal,
    GTFriendsListViewModeSelection,
} GTFriendsListViewMode;

@protocol GTFriendsSelectedDelegate <NSObject>
- (void)friendsSelected:(NSArray *)friends;
@end

@interface GTFriendsListViewController : TABaseViewController
@property (nonatomic, assign) id <GTFriendsSelectedDelegate> delegate;
@property (nonatomic, assign) GTFriendsListViewMode viewMode;
@property (nonatomic, strong) NSMutableArray *selectedFriends;

@end
