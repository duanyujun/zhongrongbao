//
//  BIDIncomeCalendarCell.h
//  zhongrongbao
//
//  Created by mal on 15/6/27.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDIncomeCalendarCell : UITableViewCell

/**
 *还款日期
 */
@property (strong, nonatomic) IBOutlet UILabel *repayDateLabel;
/**
 *还款类型
 */
@property (strong, nonatomic) IBOutlet UILabel *repayTypeLabel;
/**
 *还款数
 */
@property (strong, nonatomic) IBOutlet UILabel *repayCountLabel;
/**
 *还款状态
 */
@property (strong, nonatomic) IBOutlet UILabel *repayStatusLabel;

@end
