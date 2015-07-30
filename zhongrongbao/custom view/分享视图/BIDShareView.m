//
//  BIDShareView.m
//  zhongrongbao
//
//  Created by mal on 14-8-17.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDShareView.h"
#import "BIDResponseView.h"
#import "BIDAppDelegate.h"
#import "TencentOpenAPI/QQApiInterface.h"

@implementation BIDShareView
@synthesize delegate;
@synthesize shareText;
@synthesize shareURL;

+ (void)onResp:(QQBaseResp *)resp
{
    switch (resp.type)
    {
        case ESENDMESSAGETOQQRESPTYPE:
        {
            SendMessageToQQResp* sendResp = (SendMessageToQQResp*)resp;
            BIDResponseView *responseView = (BIDResponseView*)[[[NSBundle mainBundle] loadNibNamed:@"BIDResponseView" owner:self options:nil] lastObject];
            //分享成功
            if([sendResp.result isEqualToString:@"0"])
            {
                responseView.response = @"分享成功";
                responseView.imgName = @"success.png";
            }
            else
            {
                //分享失败
                responseView.response = @"分享失败";
                responseView.imgName = @"failure.png";
            }
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            __block CGRect responseViewFrame = responseView.frame;
            responseViewFrame.origin.x = screenSize.width/2 - CGRectGetWidth(responseViewFrame)/2;
            responseViewFrame.origin.y = screenSize.height/2 - CGRectGetHeight(responseViewFrame)/2;
            responseView.frame = responseViewFrame;
            responseView.alpha = 0;
            [keyWindow addSubview:responseView];
            [UIView animateWithDuration:1.5f animations:^{
                responseView.alpha = 1.0f;
            } completion:^(BOOL finished){
                responseView.alpha = 0.0f;
                [responseView removeFromSuperview];
            }];
//            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:sendResp.result message:sendResp.errorDescription delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
            break;
        }
        default:
        {
            break;
        }
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //self.layer.borderWidth = 1;
    //self.layer.borderColor = [UIColor colorWithRed:40.0f/255.0f green:153.0f/255.0f blue:213.0f/255.0f alpha:1.0f].CGColor;
}


- (void)showShareView
{
    if(_bShow) return;
    _bShow = YES;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    [_bgView setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.6]];
    __block CGRect ownFrame = self.frame;
    ownFrame.origin.y = screenSize.height;
    self.frame = ownFrame;
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:_bgView];
    [keyWindow addSubview:self];
    [UIView animateWithDuration:0.5f animations:^{
        ownFrame.origin.y = screenSize.height - CGRectGetHeight(ownFrame);
        self.frame = ownFrame;
    }];
}

- (void)hideShareView
{
    if(!_bShow) return;
    _bShow = NO;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    [UIView animateWithDuration:0.5f animations:^{
        CGRect ownFrame = self.frame;
        ownFrame.origin.y = screenSize.height;
        self.frame = ownFrame;
    } completion:^(BOOL finished){
        if(finished)
        {
            [_bgView removeFromSuperview];
            [self removeFromSuperview];
        }
    }];
}

- (IBAction)btnDownHandler:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    if(btn.tag != 2)
    {
        //判断微信是否已经安装
        BOOL bInstalled = [WXApi isWXAppInstalled];
        if(!bInstalled)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"微信尚未安装，是否安装" delegate:self cancelButtonTitle:@"不安装" otherButtonTitles:@"安装", nil];
            [alertView show];
        }
    }
    switch(btn.tag)
    {
        case 0:
        {
            //微信好友
            [BIDAppDelegate setPlatformType:PLATFORM_WEIXIN];
            [delegate shareTypeSelect:WECHAT_FRIEND];
            _scene = WXSceneSession;
            [self shareLinkContent];
        }
            break;
        case 1:
        {
            //微信朋友圈
            [BIDAppDelegate setPlatformType:PLATFORM_WEIXIN];
            [delegate shareTypeSelect:WECHAT_FRIEND_CIRCLE];
            _scene = WXSceneTimeline;
            [self shareLinkContent];
        }
            break;
        case 2:
        {
            //qq
            [BIDAppDelegate setPlatformType:PLATFORM_QQ];
//            QQApiTextObject *txtObj = [QQApiTextObject objectWithText:@"123"];
//            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
            
//            QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:shareURL] title:@"1" description:@"1"previewImageData:imgData];
            NSString *utf8String = self.shareURL;
            NSString *strTitle = @" ";
            NSString *strDescription = @" ";
            QQApiNewsObject *newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:utf8String ? : @""]
                                                                title:strTitle
                                                          description:strDescription
                                                     previewImageData:nil];
            //[newsObj setCflag:[self shareControlFlags]];
            
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
            QQApiSendResultCode sent = 0;
            //分享到QQ
            sent = [QQApiInterface sendReq:req];
            [self handleSendResult:sent];
        }
            break;
        case 3:
        {
            //取消
            [self hideShareView];
        }
            break;
    }
}

/**
 *分享图片
 */
- (void)shareImageContent
{
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:[UIImage imageNamed:@"res5thumb.png"]];
    
    WXImageObject *ext = [WXImageObject object];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"res5thumb" ofType:@"png"];
    ext.imageData = [NSData dataWithContentsOfFile:filePath];
    UIImage* image = [UIImage imageWithData:ext.imageData];
    ext.imageData = UIImagePNGRepresentation(image);
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = _scene;
    
    [WXApi sendReq:req];
}

/**
 *分享url链接
 */
- (void)shareLinkContent
{
    WXMediaMessage *message = [WXMediaMessage message];
    //message.title = @"专访张小龙：产品之上的世界观";
    //message.description = @"微信的平台化发展方向是否真的会让这个原本简洁的产品变得臃肿？在国际化发展方向上，微信面临的问题真的是文化差异壁垒吗？腾讯高级副总裁、微信产品负责人张小龙给出了自己的回复。";
    //[message setThumbImage:[UIImage imageNamed:@"res2.png"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = shareURL;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = _scene;
    
    [WXApi sendReq:req];
}

/**
 *分享纯文本
 */
- (void)shareTextContent
{
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    //req.text = @"人文的东西并不是体现在你看得到的方面，它更多的体现在你看不到的那些方面，它会影响每一个功能，这才是最本质的。但是，对这点可能很多人没有思考过，以为人文的东西就是我们搞一个很小清新的图片什么的。”综合来看，人文的东西其实是贯穿整个产品的脉络，或者说是它的灵魂所在。";
    req.text = shareText;
    req.bText = YES;
    req.scene = _scene;
    
    [WXApi sendReq:req];
}

- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQZONENOTSUPPORTTEXT:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"空间分享不支持纯文本分享，请使用图文分享" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQZONENOTSUPPORTIMAGE:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"空间分享不支持纯图片分享，请使用图文分享" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        default:
        {
            break;
        }
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex)
    {
        case 0:
        {
            //不安装
        }
            break;
        case 1:
        {
            //安装
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[WXApi getWXAppInstallUrl]]];
        }
            break;
    }
}

@end
