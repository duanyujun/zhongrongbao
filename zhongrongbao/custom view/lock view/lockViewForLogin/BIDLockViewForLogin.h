//
//  BIDLockViewForLogin.h
//  mashangban
//
//  Created by mal on 14-8-11.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BIDLockViewForLoginDelegate <NSObject>

- (void)gestureUnlockFailed:(int)failedTimes;
- (void)gestureUnlockSuccess;

@end

@interface BIDLockViewForLogin : UIView
{
    /**
     *保存9个按钮
     */
    NSMutableArray *_btnsArr;
    /**
     *按顺序保存选中的按钮
     */
    NSMutableArray *_choosedArr;
    
    CGPoint _curPt;
    
    BOOL _bFinish;
    BOOL _bSame;
}

@property (copy, nonatomic)NSString *trackPath;
@property (copy, nonatomic)NSString *rightTrackPath;
@property (assign, nonatomic) id<BIDLockViewForLoginDelegate> delegate;

@end
