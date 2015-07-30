//
//  BIDRechargeAndWithdrawalViewController.h
//  zhongrongbao
//
//  Created by mal on 14-8-18.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIDBaseViewController.h"
extern const int kSlideDistance;

@interface BIDRechargeAndWithdrawalViewController : BIDBaseViewController
{
    IBOutlet UISegmentedControl *_mySegmentedControl;
    IBOutlet UIView *_segmentedCtrlBgView;
}

@end
