//
//  BIDLogoutView.m
//  zhongrongbao
//
//  Created by mal on 14-10-17.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDLogoutView.h"

@implementation BIDLogoutView
@synthesize delegate;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)loginBtnHandler:(id)sender
{
    [delegate toLoginOrRegisterByType:ACTION_LOGIN];
}

- (IBAction)registerBtnHandler:(id)sender
{
    [delegate toLoginOrRegisterByType:ACTION_REGISTER];
}

@end
