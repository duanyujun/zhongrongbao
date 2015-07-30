//
//  BIDPersonalSettingsViewController.h
//  zhongrongbao
//
//  Created by mal on 14-8-25.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDBaseViewController.h"

@interface BIDPersonalSettingsViewController : BIDBaseViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *_myTableView;
    IBOutlet UIButton *_logoutBtn;
}

@end
