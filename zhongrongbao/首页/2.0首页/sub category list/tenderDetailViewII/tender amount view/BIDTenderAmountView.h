//
//  BIDTenderAmountView.h
//  zhongrongbao
//
//  Created by mal on 15/7/5.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BIDTenderAmountViewDelegate <NSObject>

- (void)toTenderWithAmount:(NSString*)strAmount password:(NSString*)strPwd activityId:(NSString*)strActivityIds;
- (void)cancelTender;
- (void)showActivityList:(CGRect)frame type:(int)type;
- (void)hideActivityList;

@end

@interface BIDTenderAmountView : UIView
{
    //账户余额
    IBOutlet UILabel *_leftAmountLabel;
    //可投金额
    IBOutlet UILabel *_canInvestAmtLabel;
    //投标金额
    IBOutlet UITextField *_amountTF;
    //使用红包
    IBOutlet UITextField *_redPacketTF;
    //使用体验金
    IBOutlet UITextField *_tiyanjinTF;
    //取消按钮
    IBOutlet UIButton *_cancelBtn;
    //确认投标按钮
    IBOutlet UIButton *_confirmBtn;
    //
    IBOutlet UIButton *_maskForRedPacketBtn;
    //
    IBOutlet UIButton *_maskForTiYanJinBtn;
    //
    IBOutlet UIView *_bgViewForPwd;
    //投标密码输入框
    IBOutlet UITextField *_pwdTF;
    IBOutlet UILabel *_pwdLable;
    //约束
    //密码框
    IBOutlet NSLayoutConstraint *_heightConstraintForPwdView;
    IBOutlet NSLayoutConstraint *_topConstraintForPwdView;
    //红包
    IBOutlet NSLayoutConstraint *_heightConstraintForRedPacket;
    IBOutlet NSLayoutConstraint *_topConstraintForRedPacket;
    //体验金
    IBOutlet NSLayoutConstraint *_heightConstraintForTiYanJin;
    IBOutlet NSLayoutConstraint *_topConstraintForTiYanJin;
    //红包按钮
    IBOutlet NSLayoutConstraint *_heightConstraintForBtn1;
    IBOutlet NSLayoutConstraint *_topConstraintForBtn1;
    //体验金按钮
    IBOutlet NSLayoutConstraint *_heightConstraintForBtn2;
    IBOutlet NSLayoutConstraint *_topConstraintForBtn2;
}

@property (assign, nonatomic) id<BIDTenderAmountViewDelegate> delegate;

- (void)setRedPacket:(NSString*)strActName;
- (void)setTiYanJin:(NSString*)strActName;
/**
 *账户余额
 */
@property (assign, nonatomic) CGFloat leftAmount;
/**
 *可投金额
 */
@property (assign, nonatomic) CGFloat canInvestAmt;
/**
 *  显示、隐藏红包按钮
 */
- (void)showOrHideRedPacketOption:(BOOL)bShow;
/**
 *  显示、隐藏体验金
 */
- (void)showOrHideTiYanJinOption:(BOOL)bShow;
/**
 *显示、隐藏投标密码编辑框
 */
- (void)showOrHidePasswordOption:(BOOL)bShow;
/**
 *每次投完标需要清掉保存的活动id
 */
- (void)clearActivityId;

@end
