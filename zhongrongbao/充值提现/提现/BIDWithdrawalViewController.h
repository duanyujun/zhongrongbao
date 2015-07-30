//
//  BIDWithdrawalViewController.h
//  zhongrongbao
//
//  Created by mal on 14-10-16.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIDBaseViewController.h"

@interface BIDWithdrawalViewController : BIDBaseViewController
{
    IBOutlet UITableView *_tableView;
}

/**
 *设置可用余额
 */
- (void)setAvailableAmt:(NSString*)strAmount;

@end
