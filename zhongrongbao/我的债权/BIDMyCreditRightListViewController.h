//
//  BIDMyCreditRightListViewController.h
//  zhongrongbao
//
//  Created by mal on 14-10-16.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"
#import "BIDMyTableView.h"

@interface BIDMyCreditRightListViewController : BIDBaseViewController
{
    IBOutlet BIDMyTableView *_creditRightListView;
    IBOutlet UIView *_bgView;
    IBOutlet UISegmentedControl *_segmentedControl;
}

@property (assign, nonatomic) int selectedIndex;

@end
