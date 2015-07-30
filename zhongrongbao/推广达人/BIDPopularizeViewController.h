//
//  BIDPopularizeViewController.h
//  zhongrongbao
//
//  Created by mal on 14-9-1.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"

@interface BIDPopularizeViewController : BIDBaseViewController
/**
 *推广收益
 */
@property (strong, nonatomic) IBOutlet UILabel *popularizeIncomeLabel;
/**
 *推广人数
 */
@property (strong, nonatomic) IBOutlet UILabel *popularizePeopleCountLabel;
/**
 *分享按钮
 */
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;
/**
 *二维码图片view
 */
@property (strong, nonatomic) IBOutlet UIImageView *imgView;

- (IBAction)shareBtnHandler:(id)sender;

@end
