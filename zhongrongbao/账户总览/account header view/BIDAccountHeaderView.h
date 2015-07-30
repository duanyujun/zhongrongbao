//
//  BIDAccountHeaderView.h
//  zhongrongbao
//
//  Created by mal on 14-8-26.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDAccountHeaderView : UIView
{
    IBOutlet UILabel *_flagLabel1;
    IBOutlet UILabel *_flagLabel2;
    IBOutlet UILabel *_flagLabel3;
    IBOutlet UILabel *_flagLabel4;
    IBOutlet UILabel *_flagLabel5;
    IBOutlet UILabel *_hintLabel1;
    IBOutlet UILabel *_hintLabel2;
    IBOutlet UILabel *_hintLabel3;
}

/**
 *用户名
 */
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
/**
 *汇付账户
 */
@property (strong, nonatomic) IBOutlet UILabel *accountLabel;
/**
 *账户总资产
 */
@property (strong, nonatomic) IBOutlet UILabel *totalAssetsLabel;
/**
 *可用余额
 */
@property (strong, nonatomic) IBOutlet UILabel *balanceLabel;
/**
 *冻结余额
 */
@property (strong, nonatomic) IBOutlet UILabel *frozenLabel;
/**
 *描述
 */
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
/**
 *累计投资
 */
@property (strong, nonatomic) IBOutlet UILabel *accumulatedTenderLabel;
/**
 *累计收益
 */
@property (strong, nonatomic) IBOutlet UILabel *accumulatedIncomeLabel;
/**
 *汇付总金额
 */
@property (strong, nonatomic) IBOutlet UILabel *totalAccountLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalAccountFlagLabel;
@property (copy, nonatomic) NSString *totalAmount;
/**
 *冻结余额与可用余额的百分比
 */
@property (assign, nonatomic) CGFloat rate;

- (void)initView;

- (void)refreshView;

/**
 *显示（请先注册汇付天下）
 */
- (void)showHintMsgLabel;
- (void)hideHintMsgLabel;

@end
