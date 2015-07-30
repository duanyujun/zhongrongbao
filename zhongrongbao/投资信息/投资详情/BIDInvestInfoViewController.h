//
//  BIDInvestInfoViewController.h
//  zhongrongbao
//
//  Created by mal on 14-10-15.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum BUTTON_TYPE
{
    //转让债券、撤销投资、无类型
    BUTTON_TRANSFER, BUTTON_WITHDRAW, BUTTON_NULL
}BUTTON_TYPE;

@interface BIDInvestInfoViewController : UITableViewController

/**
 *投资id
 */
@property (copy, nonatomic) NSString *investId;

@end
