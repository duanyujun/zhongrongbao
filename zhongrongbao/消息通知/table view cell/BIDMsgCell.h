//
//  BIDMsgCell.h
//  zhongrongbao
//
//  Created by mal on 14/12/26.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDMsgCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;

@end
