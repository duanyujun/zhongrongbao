//
//  BIDAccountCell.h
//  zhongrongbao
//
//  Created by mal on 14-8-28.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDAccountCell : UITableViewCell
/**
 *日期
 */
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
/**
 *类型
 */
@property (strong, nonatomic) IBOutlet UILabel *typeLabel;
/**
 *钱数
 */
@property (strong, nonatomic) IBOutlet UILabel *moneyLabel;

@end
