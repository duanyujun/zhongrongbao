//
//  BIDLogoutView.h
//  zhongrongbao
//
//  Created by mal on 14-10-17.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum ACTION_TYPE
{
    ACTION_LOGIN, ACTION_REGISTER
}ACTION_TYPE;

@protocol BIDLogoutViewDelegate <NSObject>

- (void)toLoginOrRegisterByType:(ACTION_TYPE)actionType;

@end

@interface BIDLogoutView : UIView
{
    //登录按钮
    IBOutlet UIButton *_loginBtn;
    //注册按钮
    IBOutlet UIButton *_registerBtn;
}

@property (assign, nonatomic) id<BIDLogoutViewDelegate> delegate;

- (IBAction)loginBtnHandler:(id)sender;
- (IBAction)registerBtnHandler:(id)sender;

@end
