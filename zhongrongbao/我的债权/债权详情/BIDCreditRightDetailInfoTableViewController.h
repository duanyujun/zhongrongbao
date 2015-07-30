//
//  BIDCreditRightDetailInfoTableViewController.h
//  zhongrongbao
//
//  Created by mal on 14-10-16.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum BUTTON_TYPE
{
    //发布、撤销、修改
    BUTTON_PUBLISH, BUTTON_WITHDRAW, BUTTON_EDIT, BUTTON_NULL
}BUTTON_TYPE;

@interface BIDCreditRightDetailInfoTableViewController : UITableViewController

@property (copy, nonatomic) NSString *investId;

@end
