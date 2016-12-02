//
//  GTMutualFriendsView.m
//  goTogether
//
//  Created by shirish gone on 15/12/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTMutualFriendsView.h"
#import "GTMutualFriendCell.h"
#import "GTMutualFriend.h"
#import "UIImage+TAExtensions.h"

NSString *kDetailedViewControllerID = @"DetailView";
NSString *kCellID = @"mutual_friend";
NSString *kZeroCellID = @"zero_mutual_friends";

@interface  GTMutualFriendsView()
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, readwrite) NSInteger mutualFriendCount;
@end

@implementation GTMutualFriendsView

- (void)setMutualFriendsArray:(NSArray *)mutualFriendsArray {
    _mutualFriendsArray = mutualFriendsArray;
    _mutualFriendCount = [mutualFriendsArray count];
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
    if (self.mutualFriendCount == 0) {
        return 1;
    }else{
        return self.mutualFriendCount;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (self.mutualFriendCount == 0) {
        UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kZeroCellID
                                                                 forIndexPath:indexPath];
        
        return cell;
        
    }else {
        GTMutualFriendCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID
                                                                 forIndexPath:indexPath];
        
        Friend *friend = [self.mutualFriendsArray objectAtIndex:indexPath.row];
        
        [self setFriendName:friend.friendName inCell:cell];
        [self setPictureOfFacebookId:friend.friendId
                        forTableCell:cell
                        forIndexPath:indexPath];
        return cell;
    }
}

- (void)setFriendName:(NSString *)friendName inCell:(GTMutualFriendCell *)cell {
    NSArray *nameComponents = [friendName componentsSeparatedByString:@" "];
    if ([nameComponents count] > 0) {
        NSString *firstName = [nameComponents objectAtIndex:0];
        [cell setName:firstName];
    }
}

- (void)setPictureOfFacebookId:(NSString *)userId
            forTableCell:(GTMutualFriendCell *)tableCell
            forIndexPath:(NSIndexPath *)indexPath {
    if ([UIImage isImageAvailableInCacheForUserId:userId]) {
        UIImage *cachedImage = [UIImage cachedImageforUserId:userId];
        [tableCell setProfilePic:cachedImage];
    }else {
        if ([UIImage isAvailableLocallyForUserId:userId]) {
            
            NSString *imageFilePath = [UIImage filePathForUserId:userId];
            UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
            [tableCell setProfilePic:image];
            
            [UIImage updateImageForUserId:userId
                                  success:^(UIImage *image) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          

    GTMutualFriendCell * cell = (GTMutualFriendCell *)[self.collectionView
                                                       cellForItemAtIndexPath:indexPath];
    [cell setProfilePic:image];
                                      });
                                  } failure:^(NSError *error) {
                                  }];
        }else{
            UIImage *defaultImage = [UIImage imageNamed:@"ico_user_40"];
            [tableCell setProfilePic:defaultImage];
            [UIImage
             downloadImageForUserId:userId
             success:^(UIImage *image) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                    GTMutualFriendCell * cell = (GTMutualFriendCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                     [cell setProfilePic:image];
                 });
             } failure:^(NSError *error) {
             }];
            
        }
    }
    
}


@end
