//
//  BIDSetPasswordViewController.m
//  shangwuting
//
//  Created by mal on 14-1-2.
//  Copyright (c) 2014年 mal. All rights reserved.
//

#import "BIDSetPasswordViewController.h"
#import "BIDLoginViewController.h"
#import "BIDAppDelegate.h"
#import "BIDDataCommunication.h"

static NSString *strSetPasswordURL = @"UserAccount/passwordChange.shtml";

@interface BIDSetPasswordViewController ()<UIAlertViewDelegate>

{
    /**
     *旧密码
     */
    NSString *_oldPassword;
}

@end

@implementation BIDSetPasswordViewController
@synthesize oldPasswordTF;
@synthesize firstPasswordTF;
@synthesize secondPasswordTF;
@synthesize label1;
@synthesize label2;
@synthesize label3;
@synthesize label4;
@synthesize confirmBtn;
@synthesize bOldPasswordWrong;
@synthesize bFirstPasswordWrong;
@synthesize bSecondPasswordWrong;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"修改密码";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    bOldPasswordWrong = NO;
    bFirstPasswordWrong = NO;
    bSecondPasswordWrong = NO;
    
    oldPasswordTF.inputAccessoryView = self.toolBar;
    firstPasswordTF.inputAccessoryView = self.toolBar;
    secondPasswordTF.inputAccessoryView = self.toolBar;
    UIColor *color = [UIColor colorWithRed:198.0f/255.0f green:199.0f/255.0f blue:199.0f/255.0f alpha:1.0f];
    oldPasswordTF.layer.borderWidth = 1;
    oldPasswordTF.layer.borderColor = color.CGColor;
    firstPasswordTF.layer.borderWidth = 1;
    firstPasswordTF.layer.borderColor = color.CGColor;
    secondPasswordTF.layer.borderWidth = 1;
    secondPasswordTF.layer.borderColor = color.CGColor;
    
    label1.layer.borderWidth = 1;
    label1.layer.borderColor = [UIColor brownColor].CGColor;
    
    label2.layer.borderWidth = 1;
    label2.layer.borderColor = [UIColor brownColor].CGColor;
    
    label3.layer.borderWidth = 1;
    label3.layer.borderColor = [UIColor brownColor].CGColor;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect ownFrame = self.view.frame;
    ownFrame.size.height = screenSize.height - 64;
    self.view.frame = ownFrame;
    
    CGRect frame = confirmBtn.frame;
    frame.origin.y = ownFrame.size.height-20-frame.size.height;
    confirmBtn.frame = frame;
    
    [BIDCommonMethods setImgForBtn:confirmBtn imgForNormal:@"redBtnBgNormal" imgForPress:@"redBtnBgPress" inset:UIEdgeInsetsMake(10, 10, 11, 11)];
    
    _oldPassword = [self getOldPassword];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    oldPasswordTF = nil;
    firstPasswordTF = nil;
    secondPasswordTF = nil;
    label1 = nil;
    label2 = nil;
    label3 = nil;
    label4 = nil;
    confirmBtn = nil;
}

/**
 *获取旧的密码
 */
- (NSString*)getOldPassword
{
    NSString *password = @"";
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if(arr.count>0)
    {
        NSString *configPath = [arr[0] stringByAppendingPathComponent:@"config.plist"];
        if([[NSFileManager defaultManager] fileExistsAtPath:configPath])
        {
            NSDictionary *configDictionary = [[NSDictionary alloc] initWithContentsOfFile:configPath];
            password = [configDictionary objectForKey:@"password"];
        }
        else
        {
        }
    }
    return password;
}

//确定
- (IBAction)confirmBtnHandler:(id)sender
{
    if(oldPasswordTF.text.length==0)
    {
        label1.hidden = NO;
        label1.text = @"您尚未填写当前密码";
        return;
    }
    if(bSecondPasswordWrong)
    {
        label3.hidden = NO;
        return;
    }
    if(bFirstPasswordWrong)
    {
        label2.hidden = NO;
        label4.hidden = YES;
        return;
    }
    if(![oldPasswordTF.text isEqualToString:_oldPassword])
    {
        label1.text = @"旧密码有误";
        label1.hidden = NO;
        return;
    }
    //修改密码
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strSetPasswordURL];
    NSString *strOldPassword = _oldPassword;
    NSString *strNewPasswordFirst = firstPasswordTF.text;
    NSString *strNewPasswordSecond = secondPasswordTF.text;
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"pwd\":\"%@\", \"pwdChange_one\":\"%@\", \"pwdChange_two\":\"%@\"}", strOldPassword, strNewPasswordFirst, strNewPasswordSecond];
    self.spinnerView.content = @"修改密码..";
    [self.spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        int rev = [BIDDataCommunication uploadDataByPostToURL:strURL postValue:strPost toDictionary:dictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinnerView dismissTheView];
            if(rev==1)
            {
                if([[dictionary objectForKey:@"json"] isEqualToString:@"success"])
                {
                    NSString *strConfigPath = [BIDCommonMethods getConfigPath];
                    NSMutableDictionary *configInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:strConfigPath];
                    [configInfo setObject:strNewPasswordFirst forKey:@"password"];
                    [configInfo writeToFile:strConfigPath atomically:YES];
                    [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:self tag:0];
                }
                else
                {
                    [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:nil tag:0];
                }
            }
            else if(rev==2)
            {
                [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:self tag:2];
            }
            else
            {
                [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
            }
        });
    });
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    label1.hidden = YES;
    label2.hidden = YES;
    label3.hidden = YES;
    label4.hidden = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch(textField.tag)
    {
        case 0:
        {
            //旧密码
        }
            break;
        case 1:
        {
            //新密码
            NSRegularExpression *regExpression = [[NSRegularExpression alloc] initWithPattern:@"^[a-zA-Z0-9]{6,16}$" options:NSRegularExpressionCaseInsensitive error:nil];
            NSUInteger matchCount = 0;
            if(firstPasswordTF.text.length==0)
            {
                matchCount = 0;
                firstPasswordTF.text = @"";
            }
            else
            {
                matchCount = [regExpression numberOfMatchesInString:firstPasswordTF.text options:NSMatchingReportProgress range:NSMakeRange(0, firstPasswordTF.text.length)];
            }
            if(matchCount==0)
            {
                label2.hidden = NO;
                label4.hidden = YES;
                bFirstPasswordWrong = YES;
            }
            else
            {
                bFirstPasswordWrong = NO;
            }
        }
            break;
        case 2:
        {
            //再次输入
            NSString *str1 = firstPasswordTF.text;
            NSString *str2 = secondPasswordTF.text.length==0?@"":secondPasswordTF.text;
            if([str1 isEqualToString:str2])
            {
                bSecondPasswordWrong = NO;
            }
            else
            {
                label3.hidden = NO;
                bSecondPasswordWrong = YES;
            }
        }
            break;
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(alertView.tag==2)
    {
        //登录
        BIDLoginViewController *vc;
        if(IPHONE4OR4S)
        {
            vc = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController" bundle:nil];
        }
        else
        {
            vc = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController2" bundle:nil];
        }
        vc.bRequestException = YES;
        [self.navigationController setViewControllers:@[vc] animated:YES];
    }
}

@end
