//
//  BIDRoomMortgageView.h
//  zhongrongbao
//
//  Created by mal on 14-9-11.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDRoomMortgageView : UIView
{
    IBOutlet UILabel *_titleLabel;
}
/**
 *土地亩数
 */
@property (strong, nonatomic) IBOutlet UILabel *landAreaLabel;
/**
 *可用年限
 */
@property (strong, nonatomic) IBOutlet UILabel *canUseYearLabel;
/**
 *土地参考价值
 */
@property (strong, nonatomic) IBOutlet UILabel *landReferenceValueLabel;
/**
 *小区名称
 */
@property (strong, nonatomic) IBOutlet UILabel *villageNameLabel;
/**
 *建筑面积
 */
@property (strong, nonatomic) IBOutlet UILabel *constructionAreaLabel;
/**
 *产权
 */
@property (strong, nonatomic) IBOutlet UILabel *propertyRightsLabel;
/**
 *评估价值
 */
@property (strong, nonatomic) IBOutlet UILabel *assessedValueLabel;
/**
 *参考价值
 */
@property (strong, nonatomic) IBOutlet UILabel *referenceValueLabel;

- (void)initView;

@end
