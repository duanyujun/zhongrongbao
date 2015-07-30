//
//  BIDLockViewController.h
//  mashangban
//
//  Created by mal on 14-8-11.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIDBaseViewController.h"
@class BIDLockViewForSet;
@class BIDLockViewForLogin;

@interface BIDLockViewController : BIDBaseViewController
{
    BIDLockViewForSet *_lockView;
    BIDLockViewForLogin *_lockViewForLogin;
}

@property (assign, nonatomic)BOOL bLogin;

- (void)initView;

@end
