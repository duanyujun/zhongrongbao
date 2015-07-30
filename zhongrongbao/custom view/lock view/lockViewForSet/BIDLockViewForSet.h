//
//  BIDLockView.h
//  mashangban
//
//  Created by mal on 14-8-11.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIDLockViewController.h"

@protocol BIDLockViewForSetDelegate <NSObject>

- (void)setGesturePasswordSuccess;

@end

@interface BIDLockViewForSet : UIView
{
    /**
     *保存9个小按钮
     */
    NSMutableArray *_smallBtnsArr;
    /**
     *保存9个按钮
     */
    NSMutableArray *_btnsArr;
    /**
     *按顺序保存选中的按钮
     */
    NSMutableArray *_choosedArr;
    /**
     *线段的起始点
     */
    CGPoint _startPt;
    /**
     *线段的另一头的位置
     */
    CGPoint _curPt;
    /**
     *设置完成
     */
    BOOL _bFinish;
    /**
     *第一次绘制轨迹
     */
    BOOL _bFirstTrack;
    /**
     *两次设置的轨迹是否相同
     */
    BOOL _bSame;
    /**
     *是否是有效的设置
     */
    BOOL _bEffect;
    /**
     *
     */
    UILabel *_label;
}

/**
 *用来存储手势密码
 */
@property (copy, nonatomic)NSString *firstTrackPath;
@property (copy, nonatomic)NSString *secondTrackPath;

@property (assign, nonatomic)NSObject<BIDLockViewForSetDelegate> *delegate;

@end
