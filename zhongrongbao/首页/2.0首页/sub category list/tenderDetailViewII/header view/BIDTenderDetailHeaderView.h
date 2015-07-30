//
//  BIDTenderDetailHeaderView.h
//  zhongrongbao
//
//  Created by mal on 15/7/1.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDTenderDetailHeaderView : UIView
{
    IBOutlet UIView *_flagView1;
    IBOutlet UIView *_flagView2;
}
/**
 *信用
 */
@property (strong, nonatomic) IBOutlet UILabel *creditLabel;
/**
 *授信额度
 */
@property (strong, nonatomic) IBOutlet UILabel *creditLimitLabel;
/**
 *借款名
 */
@property (strong, nonatomic) IBOutlet UILabel *borrowNameLabel;
/**
 *借款金额
 */
@property (strong, nonatomic) IBOutlet UILabel *borrowAmtLabel;
/**
 *可投金额
 */
@property (strong, nonatomic) IBOutlet UILabel *canInvestAmtLabel;
/**
 *项目日期
 */
@property (strong, nonatomic) IBOutlet UILabel *deadLineLabel;
/**
 *倒计时或显示满标时间
 */
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
/**
 *年化收益
 */
@property (strong, nonatomic) IBOutlet UILabel *yearRateLabel;
/**
 *进度标志
 */
@property (strong, nonatomic) IBOutlet UILabel *progressLabel;

- (void)initView;


@end
