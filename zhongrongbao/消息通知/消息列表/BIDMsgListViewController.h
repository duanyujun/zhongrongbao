//
//  BIDMsgListViewController.h
//  zhongrongbao
//
//  Created by mal on 15/1/7.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"

@interface BIDMsgListViewController : BIDBaseViewController
{
    IBOutlet UITableView *_myTableView;
}

- (void)dismissToolBar;

@end
