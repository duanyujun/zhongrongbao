//
//  BIDIncomeCalendarViewController.h
//  zhongrongbao
//
//  Created by mal on 15/6/27.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDBaseViewControllerII.h"

@interface BIDIncomeCalendarViewController : BIDBaseViewControllerII
{
    IBOutlet UISegmentedControl *_segmentedControl;
    IBOutlet UIScrollView *_myScrollView;
}

@property (assign, nonatomic) int segmentedIndex;

@end
