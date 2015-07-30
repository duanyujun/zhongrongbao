//
//  BIDHomePageViewController.h
//  zhongrongbao
//
//  Created by mal on 14-8-12.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"
#import "BIDMyTableView.h"

@class BIDHomePageViewController;

@interface BIDTenderListView : BIDMyTableView
{
}
//此处用assign,用strong会造成内存泄露
@property (assign, nonatomic) BIDHomePageViewController *parentVC;

@end

@interface BIDHomePageViewController : BIDBaseViewController
{
    NSMutableArray *_tenderListViewArr;
    IBOutlet UIView *_bgView;
    UISegmentedControl *_segmentedControl;
    UIScrollView *_myScrollView;
    UIScrollView *_listScrollView;
}

@property (assign, nonatomic)int segmentedIndex;

@end
