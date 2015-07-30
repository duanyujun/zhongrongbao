//
//  BIDRedPacketView.h
//  zhongrongbao
//
//  Created by mal on 15/6/30.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDRedPacketView : UIView
{
}
/**
 *
 */
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
/**
 *红包名
 */
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
/**
 *红包金额
 */
@property (strong, nonatomic) IBOutlet UILabel *amountLabel;
/**
 *有效期
 */
@property (strong, nonatomic) IBOutlet UILabel *limitDateLabel;
/**
 *使用限制
 */
@property (strong, nonatomic) IBOutlet UILabel *limitLabel;
/**
 *使用状态
 */
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

@end
