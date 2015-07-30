//
//  BIDManagerInNavViewController.h
//  zhongrongbao
//
//  Created by mal on 14-8-20.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString *VIEW_CHANGE_EVENT;
extern NSString *REFRESH_USERACCOUNTINFO_EVENT;
extern const int kSlideDistance;

@interface BIDManagerInNavViewController : UIViewController

- (void)topup;

- (void)incomeCalendar;

- (void)removeMaskView;

- (void)slideToRight;

@end
