//
//  BIDCarMortgageView.h
//  zhongrongbao
//
//  Created by mal on 14-9-11.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDCarMortgageView : UIView
{
    IBOutlet UILabel *_titleLabel;
}
/**
 *车辆型号
 */
@property (strong, nonatomic) IBOutlet UILabel *vehicleTypeLabel;
/**
 *购买时间
 */
@property (strong, nonatomic) IBOutlet UILabel *boughtDateLabel;
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
