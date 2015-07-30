//
//  BIDHeaderViewForRechargeAndWithdrawal.h
//  zhongrongbao
//
//  Created by mal on 14-8-18.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BIDCustomKeyboard;
@interface BIDHeaderViewForRechargeAndWithdrawal : UIView
{
    IBOutlet UISegmentedControl *_segmentedControl;
    IBOutlet UILabel *_label1;
    IBOutlet UILabel *_label2;
    IBOutlet UITextField *_amountTF;
    IBOutlet UIView *_bgView;
    BIDCustomKeyboard *_customKeyboard;
}

- (void)initView;

@end
