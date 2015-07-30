//
//  BIDPaymentMethodListViewController.h
//  zhongrongbao
//
//  Created by mal on 15/6/29.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"

@interface BIDPaymentMethodListViewController : BIDBaseViewController
{
    IBOutlet UITableView *_tableView;
}
/**
 *要充值的金额
 */
@property (copy, nonatomic) NSString *rechargeAmount;

@end
