//
//  BIDTenderDetailViewControllerII.h
//  zhongrongbao
//
//  Created by mal on 15/7/1.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"

@interface BIDTenderDetailViewControllerII : BIDBaseViewController
{
    IBOutlet UISegmentedControl *_segmentedControl;
    IBOutlet UIButton *_investBtn;
}

/**
 *该标是否可投
 */
@property (assign, nonatomic) BOOL bCanInvest;
/**
 *是否在投标按钮上显示开标时间
 */
@property (assign, nonatomic) BOOL bShowOpenTime;
@property (copy, nonatomic) NSString *openTime;
/**
 *bid
 */
@property (copy, nonatomic) NSString *tenderId;

@end
