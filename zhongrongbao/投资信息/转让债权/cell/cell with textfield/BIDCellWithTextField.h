//
//  BIDCellWithTextField.h
//  zhongrongbao
//
//  Created by mal on 14-10-16.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIDCustomTextField.h"
@interface BIDCellWithTextField : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet BIDCustomTextField *contentTF;
@property (strong, nonatomic) IBOutlet UILabel *unitsLabel;

@end
