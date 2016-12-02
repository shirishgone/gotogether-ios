//
//  GTTableViewCellType1.h
//  goTogether
//
//  Created by shirish on 27/03/13.
//  Copyright (c) 2013 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GTTableCell_CreateRide_IconKeyValue : UITableViewCell
- (void)setIcon:(UIImage *)iconImage
            key:(NSString *)keyString
          value:(NSString *)valueString
    andRowIndex:(GTRowIndex)index;
@end
