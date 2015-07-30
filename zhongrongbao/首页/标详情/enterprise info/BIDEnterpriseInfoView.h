//
//  BIDEnterpriseInfoView.h
//  zhongrongbao
//
//  Created by mal on 14-9-10.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BIDEnterpriseInfoViewDelegate <NSObject>

- (void)refreshEnterpriseInfo;

@end

@interface BIDEnterpriseInfoView : UIView
{
    IBOutlet UIButton *btn;
    IBOutlet UIImageView *imgView;
    BOOL _bExpanded;
    /**
     *完整的经营情况
     */
    NSString *_wholeOperatingCondition;
    /**
     *部分经营情况
     */
    NSString *_partialOperatingCondition;
    /**
     *涉诉情况标题label
     */
    IBOutlet UILabel *_lawsuitTitleLabel;
    /**
     *征信情况标题label
     */
    IBOutlet UILabel *_creditTitleLabel;
}

/**
 *注册年限
 */
@property (strong, nonatomic) IBOutlet UILabel *registerYearsLabel;
/**
 *注册资金
 */
@property (strong, nonatomic) IBOutlet UILabel *registerCapitalLabel;
/**
 *资产净值
 */
@property (strong, nonatomic) IBOutlet UILabel *netAssetValueLabel;
/**
 *行业
 */
@property (strong, nonatomic) IBOutlet UILabel *industryLabel;
/**
 *上年度经营现金流入
 */
@property (strong, nonatomic) IBOutlet UILabel *cashInflowsLabel;
/**
 *经营情况
 */
@property (strong, nonatomic) IBOutlet UILabel *operatingConditionLabel;
@property (copy, nonatomic) NSString *operatingCondition;
/**
 *涉诉情况
 */
@property (strong, nonatomic) IBOutlet UILabel *lawsuitConditionLabel;
@property (copy, nonatomic) NSString *lawsuitCondition;
/**
 *征信记录
 */
@property (strong, nonatomic) IBOutlet UILabel *creditRegistriesLabel;
@property (copy, nonatomic) NSString *creditRegistries;

@property (strong, nonatomic) IBOutlet UILabel *lineLabel;

@property (assign, nonatomic) id<BIDEnterpriseInfoViewDelegate> delegate;

- (IBAction)btnDownHandler:(id)sender;

- (void)setLayout;

@end
