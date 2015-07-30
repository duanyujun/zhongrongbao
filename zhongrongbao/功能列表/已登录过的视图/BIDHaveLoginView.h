//
//  BIDHaveLoginView.h
//  zhongrongbao
//
//  Created by mal on 14-10-17.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDHaveLoginView : UIView

/**
 *总资产
 */
@property (strong, nonatomic) IBOutlet UILabel *totalAssetsLabel;
/**
 *总收益
 */
@property (strong, nonatomic) IBOutlet UILabel *totalIncomeLabel;
/**
 *旋转控件
 */
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinnerView;

@end
