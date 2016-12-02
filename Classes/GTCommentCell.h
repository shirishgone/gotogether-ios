//
//  TATripDetaillsCommentCell.h
//  goTogether
//
//  Created by shirish on 02/03/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Comment;
@interface GTCommentCell : UITableViewCell
@property (nonatomic, strong) Comment *tripComment;

+ (CGFloat)heightForCommentLabelForString:(NSString *)string;
@end
