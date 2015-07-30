//
//  BIDCategoryListHeaderView.h
//  zhongrongbao
//
//  Created by mal on 15/6/25.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BIDCategoryListHeaderViewDelegate <NSObject>

- (void)toLogin;

@end

@interface BIDCategoryListHeaderView : UIView
{
    /**
     *账户总额
     */
    IBOutlet UILabel *_accountLabel;
    /**
     *余额
     */
    IBOutlet UILabel *_balanceLabel;
    /**
     *收益
     */
    IBOutlet UILabel *_incomeLabel;
    /**
     *登录查看
     */
    IBOutlet UIButton *_btn;
}

@property (assign, nonatomic) id<BIDCategoryListHeaderViewDelegate> delegate;

- (void)setAccount:(NSString*)strAccount;
- (void)setBalance:(NSString*)strBalance;
- (void)setIncome:(NSString*)strIncome;
- (void)setViewState:(int)state;

@end
