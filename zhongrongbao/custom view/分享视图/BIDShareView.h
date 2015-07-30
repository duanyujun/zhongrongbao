//
//  BIDShareView.h
//  zhongrongbao
//
//  Created by mal on 14-8-17.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"

typedef enum SHARE_TYPE
{
    WECHAT_FRIEND,//微信好友
    WECHAT_FRIEND_CIRCLE, //微信朋友圈
    QQ_FRIEND//qq好友
}SHARE_TYPE;

@protocol BIDShareViewDelegate <NSObject>

- (void)shareTypeSelect:(SHARE_TYPE)shareType;

@end

@interface BIDShareView : UIView<UIAlertViewDelegate>
{
    /**
     *微信好友
     */
    IBOutlet UIButton *_weFriendBtn;
    /**
     *微信朋友圈
     */
    IBOutlet UIButton *_weFriendCircleBtn;
    /**
     *qq好友
     */
    IBOutlet UIButton *_qqBtn;
    /**
     *分享视图是否已经显示
     */
    BOOL _bShow;
    /**
     *半透明背景视图
     */
    UIView *_bgView;
    /**
     *微信分享类型
     */
    enum WXScene _scene;
}

@property (assign, nonatomic) id<BIDShareViewDelegate> delegate;

/**
 *分享的url
 */
@property (copy, nonatomic) NSString *shareURL;
/**
 *分享的文本
 */
@property (copy, nonatomic) NSString *shareText;

- (IBAction)btnDownHandler:(id)sender;

/**
 *显示分享视图
 */
- (void)showShareView;
/**
 *隐藏分享视图
 */
- (void)hideShareView;

@end
