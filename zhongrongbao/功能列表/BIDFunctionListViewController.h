//
//  BIDFunctionListView.h
//  zhongrongbao
//
//  Created by mal on 14-8-12.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "BIDHomePageViewController.h"

extern  NSString *VIEW_CHANGE_EVENT;
extern NSString *REFRESH_USERACCOUNTINFO_EVENT;
extern NSString *REFRESH_PORTRAIT_EVENT;

typedef enum USER_STATUS
{
    STATUS_LOGIN, STATUS_LOGOUT
}USER_STATUS;

@protocol BIDFunctionListViewControllerDelegate <NSObject>
/**
 *
 */
- (void)showTargetVCByIndex:(int)index;

@end
@interface BIDFunctionListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    /**
     *头像图片
     */
    IBOutlet UIImageView *_imgView;
    /**
     *角标label
     */
    IBOutlet UILabel *_badgeLabel;
    /**
     *总资产
     */
    IBOutlet UILabel *_totalAssetLabel;
    /**
     *总收益
     */
    IBOutlet UILabel *_totalIncomeLabel;
    /**
     *列表
     */
    IBOutlet UITableView *_tableView;
    /**
     *功能名字数组
     */
    NSArray *_functionNameArr;
    /**
     *每个功能对应的图片的名字数组
     */
    NSArray *_imgNameArr;
    /**
     *滑动手势
     */
    UISwipeGestureRecognizer *_swipeGesture;
}
/**
 *用户状态(登录和未登录)
 */
@property (assign, nonatomic) USER_STATUS userStatus;

/**
 *总资产
 */
@property (copy, nonatomic) NSString *totalAsset;
/**
 *总收益
 */
@property (copy, nonatomic) NSString *totalIncome;

/**
 *functionListView是否已显示
 */
@property (assign, nonatomic) BOOL bHaveShow;

@property (assign, nonatomic) id<BIDFunctionListViewControllerDelegate> delegate;

- (void)initView;

/**
 *设置头像图片
 */
- (void)setPortrait;

@end
