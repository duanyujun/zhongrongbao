//
//  BIDHintView.h
//  mashangban
//
//  Created by mal on 14-8-11.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BIDHintView : UIView
{
    UILabel *_label;
}

@property (copy, nonatomic)NSString *msg;
- (void)setMsg:(NSString *)msg;

@end
