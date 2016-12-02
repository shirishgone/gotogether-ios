//
//  TATripDetaillsCommentCell.m
//  goTogether
//
//  Created by shirish on 02/03/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTCommentCell.h"
#import "Comment.h"
#import "UIImage+TAExtensions.h"
#import "TAFacebookManager.h"
#import "User.h"
#import "UIImageView+GTExtensions.h"
#import "NSString+GTExtensions.h"

@interface GTCommentCell ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateTimeLabel;
@end

@implementation GTCommentCell
- (void)setTripComment:(Comment *)tripComment{
    
    _tripComment = tripComment;

    [_commentLabel setText:tripComment.commentString];
    [_dateTimeLabel setText:[NSDate display_dataStringForDate:tripComment.commentedDate]];
    
    NSString *userId = _tripComment.commentedUserId;
    [self setUserNameValue:_tripComment.commentedUserName];
    [self setProfilePictureForUserId:userId];
}

//- (void)setUserNameForUserId:(NSString *)userId{
//    [self setUserNameValue:[User userNameForEmailId:userId]];
//}

- (void)setUserNameValue:(NSString *)userName{
    [self.userName setText:userName];
    [self layoutSubviews];    
}

- (void)setProfilePictureForUserId:(NSString *)userId{

    if ([UIImage isImageAvailableInCacheForUserId:userId]) {
        UIImage *cachedImage = [UIImage cachedImageforUserId:userId];
        [self setPicture:cachedImage];
    }else {
        if ([UIImage isAvailableLocallyForUserId:userId]) {
            
            NSString *imageFilePath = [UIImage filePathForUserId:userId];
            UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
            [self setPicture:image];
            
            [UIImage updateImageForUserId:userId
                                  success:^(UIImage *image) {
                                      [self setPicture:image];
                                  } failure:^(NSError *error) {
                                  }];
            
        }else{
            UIImage *defaultImage = [UIImage imageNamed:@"ico_user_40.png"];
            [self setPicture:defaultImage];
            
            [UIImage
             downloadImageForUserId:userId
             success:^(UIImage *image) {
                 [self setPicture:image];
             } failure:^(NSError *error) {
             }];
        }
    }
}

- (void)setPicture:(UIImage *)image{
    
    [_profilePictureView setImage:image];
    [_profilePictureView scaleProfilePic];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self adjustCommentStringFrameForString:self.tripComment.commentString];
}


+ (CGFloat)heightForCommentLabelForString:(NSString *)string{
    
    CGFloat height = [string
                      heightOfStringWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:14]
                      constrainedSize:CGSizeMake(260.0, 80.0)];

    return height;
}

- (void)adjustCommentStringFrameForString:(NSString *)string{
    CGRect frame = self.commentLabel.frame;
    CGFloat height = [GTCommentCell heightForCommentLabelForString:self.tripComment.commentString];
    frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height);
    [_commentLabel setFrame:frame];
}
@end
