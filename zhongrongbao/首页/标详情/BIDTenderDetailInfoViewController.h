//
//  BIDTenderDetailInfoViewController.h
//  zhongrongbao
//
//  Created by mal on 14-8-15.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const int kSlideDistance;

@interface BIDTenderDetailInfoViewController : UITableViewController

/**
 *标的名字
 */
@property (copy, nonatomic) NSString *tenderName;
/**
 *标的开始时间
 */
@property (copy, nonatomic) NSString *tenderStartTime;
/**
 *融资公司信息
 */
@property (copy, nonatomic) NSString *companyContent;
/**
 *融资金额
 */
@property (copy, nonatomic) NSString *financingAmount;
/**
 *年化收益
 */
@property (copy, nonatomic) NSString *incomeRate;
/**
 *融资期限
 */
@property (copy, nonatomic) NSString *financingDuration;
/**
 *还款日期
 */
@property (copy, nonatomic) NSString *repaymentDate;
/**
 *已融金额
 */
@property (copy, nonatomic) NSString *haveFinancing;
/**
 *可投金额
 */
@property (copy, nonatomic) NSString *leftFinancing;
/**
 *剩余时间
 */
@property (copy, nonatomic) NSString *leftTime;
/**
 *企业简介
 */
@property (copy, nonatomic) NSString *enterpriseBriefIntroduction;
/**
 *标的id
 */
@property (copy, nonatomic) NSString *tenderId;
/**
 *是否是集团标
 */
@property (assign, nonatomic) BOOL bIsGroupTender;
/**
 *抵押类型
 */
@property (copy, nonatomic) NSString *mortgateType;
/**
 *是否是新标预告
 */
@property (assign, nonatomic) BOOL bIsPredictTender;
/**
 *预计开标时间
 */
@property (copy, nonatomic) NSString *predictTime;

/**
 *标底视图的显示与隐藏
 */
- (void)showBottomView;
- (void)hideBottomView;

@end
