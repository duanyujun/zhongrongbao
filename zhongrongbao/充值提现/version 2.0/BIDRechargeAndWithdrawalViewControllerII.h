//
//  BIDRechargeAndWithdrawalViewControllerII.h
//  zhongrongbao
//
//  Created by mal on 15/6/28.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"

@interface BIDRechargeAndWithdrawalViewControllerII : BIDBaseViewController
{
    /**
     *用户头像
     */
    IBOutlet UIImageView *_portraitImgView;
    /**
     *用户昵称或登录名
     */
    IBOutlet UILabel *_nameLabel;
    /**
     *汇付账号
     */
    IBOutlet UILabel *_accountLabel;
    /**
     *汇付天下账户余额
     */
    IBOutlet UILabel *_balanceLabel;
    /**
     *银行卡数目
     */
    IBOutlet UILabel *_bankcardCountLabel;
    /**
     *添加或管理银行卡
     */
    IBOutlet UIButton *_addOrManageBtn;
    
}

@end
