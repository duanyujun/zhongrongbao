//
//  BIDRechargeViewController.h
//  zhongrongbao
//
//  Created by mal on 14-10-16.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"

@class BIDCustomKeyboard;
@interface BIDRechargeViewController : BIDBaseViewController
{
    IBOutlet UITextField *_amountTF;
    IBOutlet UIButton *_rechargeBtn;
    BIDCustomKeyboard *_customKeyboard;
}

- (IBAction)rechargeBtnHandler:(id)sender;

@end
