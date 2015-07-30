//
//  BIDRepaymentCell.h
//  zhongrongbao
//
//  Created by mal on 14-10-15.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDRepaymentCell : UITableViewCell
/**
 *规定还款时间
 */
@property (strong, nonatomic) IBOutlet UILabel *repayDateLabel;
/**
 *还款状态
 */
@property (strong, nonatomic) IBOutlet UILabel *repayStatusNameLabel;
/**
 *还款类型
 */
@property (strong, nonatomic) IBOutlet UILabel *repayTypeNameLabel;
/**
 *还款金额
 */
@property (strong, nonatomic) IBOutlet UILabel *repayAmtLabel;

@end
