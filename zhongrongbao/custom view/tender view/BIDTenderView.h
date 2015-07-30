//
//  BIDTenderView.h
//  zhongrongbao
//
//  Created by mal on 14-8-14.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface BIDTenderView : UIView
{
    IBOutlet UIView *_bgView;
    IBOutlet UILabel *_flagLabel1;
    IBOutlet UILabel *_flagLabel2;
}

/**
 *该标进行的百分比，即圆弧应该绘制的弧度
 */
@property (assign, nonatomic) CGFloat tenderProgress;
/**
 *标的进行百分比
 */
@property (strong, nonatomic) IBOutlet UILabel *tenderProgressLabel;
/**
 *标的当前状态（进行中、备标中）
 */
@property (strong, nonatomic) IBOutlet UILabel *tenderStateLabel;
/**
 *不显示百分比时，只显示当前标的状态
 */
@property (strong, nonatomic) IBOutlet UILabel *tenderStatusLabel;
/**
 *融资金额
 */
@property (strong, nonatomic) IBOutlet UILabel *financingAmountLabel;
@property (strong, nonatomic) IBOutlet UILabel *amountNameLable;
/**
 *年化收益率
 */
@property (strong, nonatomic) IBOutlet UILabel *incomeRateLabel;
/**
 *期限
 */
@property (strong, nonatomic) IBOutlet UILabel *deadLineLabel;
/**
 *右上角标志
 */
@property (strong, nonatomic) IBOutlet UIImageView *rightTopImgView;
/**
 *右下角标志
 */
@property (strong, nonatomic) IBOutlet UIImageView *rightBottomImgView;
/**
 *融资公司名字
 */
@property (strong, nonatomic) IBOutlet UILabel *companyNameLabel;
/**
 *融资公司信用
 */
@property (strong, nonatomic) IBOutlet UILabel *creditLabel;
/**
 *还款中
 */
@property (assign, nonatomic) BOOL bInPayment;
/**
 *金额单位:元、万元
 */
@property (strong, nonatomic) IBOutlet UILabel *amountUnitsLabel;
/**
 *开标时间
 */
@property (strong, nonatomic) IBOutlet UILabel *publishTenderDateLabel;
/**
 *标的状态
 */
@property (assign, nonatomic) TENDER_STATUS tenderStatus;

- (void)initView;

- (void)refresh;

/**
 *设置抵押标记
 */
- (void)setMortgageFlag:(NSString*)strType;

@end
