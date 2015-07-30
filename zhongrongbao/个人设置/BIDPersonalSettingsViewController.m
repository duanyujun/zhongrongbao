//
//  BIDPersonalSettingsViewController.m
//  zhongrongbao
//
//  Created by mal on 14-8-25.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDPersonalSettingsViewController.h"
#import "BIDWithTextCell.h"
#import "BIDWithImageCell.h"
#import "BIDSectionHeaderViewForPersonalSettings.h"
#import "BIDSetPortraitViewController.h"
#import "UIImage+BIDImageScale.h"
#import "BIDLoginAndRegisterViewController.h"
#import "BIDLoginViewController.h"
#import "BIDSetPasswordViewController.h"
#import "BIDLockViewController.h"
#import "BIDFunctionListViewController.h"
#import "BIDUploadFile.h"
#import "BIDEditMobilePhoneNumberFirstStepViewController.h"
#import "BIDEditNicknameViewController.h"
#import "BIDEditLoginAccountViewController.h"
#import "BIDEditEmailViewController.h"
#import "BIDGesturePasswordMenuViewController.h"
#import "BIDLoginViewController.h"
#import "BIDMyNotificationViewController.h"

/**
 *上传头像前先校验
 */
static NSString *strCheckURL = @"upload/buildKey.shtml";
/**
 *上传头像
 */
//static NSString *strUploadPortraitURL = @"UserAccount/upload.shtml";
static NSString *strUploadPortraitURL = @"upload/userUploadPhone";
/**
 *获取用户基本信息
 */
static NSString *strGetUserBaseInfoURL = @"UserAccount/queryAccount.shtml";
/**
 *退出登录
 */
static NSString *strQuitURL = @"User/logQuit.shtml";

const int ORIGINAL_MAX_WIDTH = 640;

@interface BIDPersonalSettingsViewController ()<UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, BIDSetPortraitViewControllerDelegate, BIDUploadFileDelegate, UIAlertViewDelegate>
{
    NSArray *_titleArr;
    BOOL _bRegister;
    //头像
    UIImage *_portraitImg;
    //上传文件
    BIDUploadFile *_uploadFile;
    /**
     *用户基本信息
     */
    NSDictionary *_userBaseInfoDicitonary;
}
@property (assign, nonatomic) CGRect latestFrame;
@property (assign, nonatomic) CGRect largeFrame;
@property (assign, nonatomic) CGRect oldFrame;

@end

@implementation BIDPersonalSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //
    [self getPortraitImg];
    //
    _titleArr = @[@[@""], @[@"我的消息"], @[@"修改密码", @"修改手机号", @"用户昵称", @"登录账号", @"绑定邮箱", @"修改手势密码"]]; ;
    [_myTableView setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 30)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    _myTableView.tableFooterView = footerView;
    //设置登出按钮背景图片
    UIImage *imgForNormal = [UIImage imageNamed:@"redBtnBgNormal.png"];
    UIImage *stretchImgForNormal = [imgForNormal resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 11, 11)];
    UIImage *imgForPress = [UIImage imageNamed:@"redBtnBgPress.png"];
    UIImage *stretchImgForPress = [imgForPress resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 11, 11)];
    [_logoutBtn setBackgroundImage:stretchImgForNormal forState:UIControlStateNormal];
    [_logoutBtn setBackgroundImage:stretchImgForPress forState:UIControlStateHighlighted];
    //
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getImgServerAddr], strUploadPortraitURL];
    _uploadFile = [[BIDUploadFile alloc] init];
    _uploadFile.delegate = self;
    [_uploadFile initURL:strURL];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    parent.navigationItem.titleView = nil;
    parent.navigationItem.title = @"个人设置";
    parent.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self getUserBaseInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *获取用户基本信息
 */
- (void)getUserBaseInfo
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strGetUserBaseInfoURL];
    [self.spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dicitonary = [[NSMutableDictionary alloc] init];
        int rev = [BIDDataCommunication getDataFromNet:strURL toDictionary:dicitonary];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinnerView dismissTheView];
            if(rev==1)
            {
                if([[dicitonary objectForKey:@"json"] isEqualToString:@"success"])
                {
                    _userBaseInfoDicitonary = [[NSDictionary alloc] initWithDictionary:[dicitonary objectForKey:@"data"] copyItems:YES];
                    [_myTableView reloadData];
                }
                else
                {}
            }
            else if(rev==2)
            {
                [BIDCommonMethods showAlertView:err_msg buttonTitle:@"关闭" delegate:self tag:2];
            }
            else
            {}
        });
    });
}

/**
 *退出账户
 */
- (IBAction)logoutBtnHandler:(id)sender
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strQuitURL];
    self.spinnerView.content = @"";
    [self.spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        int rev = [BIDDataCommunication getDataFromNet:strURL toDictionary:dictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinnerView dismissTheView];
            if(rev==1)
            {
                if([[dictionary objectForKey:@"json"] isEqualToString:@"success"])
                {
                    //设置用户状态为未登录
                    [BIDAppDelegate setNoLoginFlag];
                    //
                    NSString *strConfigPath = [BIDCommonMethods getConfigPath];
                    NSMutableDictionary *configDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:strConfigPath];
                    [configDictionary setObject:@"" forKey:@"username"];
                    [configDictionary setObject:@"" forKey:@"password"];
                    [configDictionary setObject:@"" forKey:@"gesturePassword"];
                    [configDictionary setObject:@0 forKey:@"gesturePasswordState"];
                    /**2015-3-2*/
                    //退出登录后，收到的推送消息是保存不了的，因为退出登录后uid会设为空
                    [configDictionary setObject:@"" forKey:@"uid"];
                    /**2015-3-2*/
                    [configDictionary writeToFile:strConfigPath atomically:YES];
                    //BIDLoginAndRegisterViewController *viewController = [[BIDLoginAndRegisterViewController alloc] initWithNibName:@"BIDLoginAndRegisterViewController" bundle:nil];
                    BIDLoginViewController *loginVC = nil;
                    if(IPHONE4OR4S)
                    {
                        loginVC = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController" bundle:nil];
                    }
                    else
                    {
                        loginVC = [[BIDLoginViewController alloc] initWithNibName:@"BIDLoginViewController2" bundle:nil];
                    }
                    NSArray *arr = @[loginVC];
                    [self.parentViewController.navigationController setViewControllers:arr];
                }
                else
                {
                    [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:nil tag:0];
                }
            }
            else
            {
                [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
            }
        });
    });
}

#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==2)
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

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _titleArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = _titleArr[section];
    return arr.count;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView;
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 20)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier";
    static NSString *textIdentifier = @"withtext";
    static NSString *imageIdentifier = @"withimage";
    NSUInteger row = indexPath.row;
    NSUInteger section = indexPath.section;
    UITableViewCell *cell = nil;
    BIDWithImageCell *imageCell = nil;
    BIDWithTextCell *textCell = nil;
    //注册cell
    if(!_bRegister)
    {
        _bRegister = YES;
        UINib *nib1 = [UINib nibWithNibName:@"BIDWithImageCell" bundle:nil];
        [tableView registerNib:nib1 forCellReuseIdentifier:imageIdentifier];
        UINib *nib2 = [UINib nibWithNibName:@"BIDWithTextCell" bundle:nil];
        [tableView registerNib:nib2 forCellReuseIdentifier:textIdentifier];
    }
    switch(section)
    {
        case 0:
        {
            //带图片的
            imageCell = (BIDWithImageCell*)[tableView dequeueReusableCellWithIdentifier:imageIdentifier];
            if(row == 0)
            {
                //头像设置
                if(_portraitImg)
                {
                    imageCell.imgView.userInteractionEnabled = YES;
                    imageCell.imgView.layer.cornerRadius = imageCell.imgView.frame.size.width/2;
                    imageCell.imgView.layer.masksToBounds = YES;
                    imageCell.imgView.image = _portraitImg;
                    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
                    [imageCell.imgView addGestureRecognizer:tapGesture];
                }
            }
            imageCell.titleLabel.text = [_userBaseInfoDicitonary objectForKey:@"userId"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell = imageCell;
        }
            break;
        case 1:
        {
            textCell = (BIDWithTextCell*)[tableView dequeueReusableCellWithIdentifier:textIdentifier];
            textCell.titleLabel.text = @"我的消息";
            textCell.contentLabel.text = @"";
            cell = textCell;
        }
            break;
        case 2:
        {
            if(row==1)
            {
                //修改手机号
                textCell = (BIDWithTextCell*)[tableView dequeueReusableCellWithIdentifier:textIdentifier];
                if(_userBaseInfoDicitonary)
                {
                    textCell.contentLabel.text = [_userBaseInfoDicitonary objectForKey:@"phone"];
                }
                else
                {
                    textCell.contentLabel.text = @"";
                }
                textCell.titleLabel.text = _titleArr[section][row];
                cell = textCell;
            }
            else if(row==2)
            {
                //用户昵称
                textCell = (BIDWithTextCell*)[tableView dequeueReusableCellWithIdentifier:textIdentifier];
                if(_userBaseInfoDicitonary)
                {
                    textCell.contentLabel.text = [_userBaseInfoDicitonary objectForKey:@"nickName"];
                }
                else
                {
                    textCell.contentLabel.text = @"";
                }
                textCell.titleLabel.text = _titleArr[section][row];
                cell = textCell;
            }
            else if(row==3)
            {
                //登录账号
                textCell = (BIDWithTextCell*)[tableView dequeueReusableCellWithIdentifier:textIdentifier];
                if(_userBaseInfoDicitonary)
                {
                    textCell.contentLabel.text = [_userBaseInfoDicitonary objectForKey:@"userId"];
                }
                else
                {
                    textCell.contentLabel.text = @"";
                }
                textCell.titleLabel.text = _titleArr[section][row];
                cell = textCell;
            }
            else if(row==4)
            {
                //绑定邮箱
                textCell = (BIDWithTextCell*)[tableView dequeueReusableCellWithIdentifier:textIdentifier];
                if(_userBaseInfoDicitonary)
                {
                    textCell.contentLabel.text = [_userBaseInfoDicitonary objectForKey:@"email"];
                }
                else
                {
                    textCell.contentLabel.text = @"";
                }
                textCell.titleLabel.text = _titleArr[section][row];
                cell = textCell;
            }
            else
            {
                cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                if(!cell)
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                }
                cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
                cell.textLabel.text = _titleArr[section][row];
                [cell.textLabel setTextColor:[UIColor darkGrayColor]];
                if(row==5)
                {
                    //修改手势密码
                    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(255, 8, 28, 28)];
                    [imgView setImage:[UIImage imageNamed:@"gesture.png"]];
                    [cell.contentView addSubview:imgView];
                }
            }
        }
            break;
    }
    [cell setBackgroundColor:[UIColor whiteColor]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    if(section == 0)
    {
        //设置头像
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相机", @"从照片库", nil];
        [actionSheet showInView:self.view];
    }
    else if(section == 1)
    {
        //我的消息
        BIDMyNotificationViewController *vc = [[BIDMyNotificationViewController alloc] initWithNibName:@"BIDMyNotificationViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if(section == 2)
    {
        //账户信息
        if(row==0)
        {
            //修改密码
            BIDSetPasswordViewController *setPasswordVC = [[BIDSetPasswordViewController alloc] initWithNibName:@"BIDSetPasswordViewController" bundle:nil];
            [self.navigationController pushViewController:setPasswordVC animated:YES];
        }
        else if(row == 1)
        {
            //修改手机号
            BIDEditMobilePhoneNumberFirstStepViewController *vc = [[BIDEditMobilePhoneNumberFirstStepViewController alloc] initWithNibName:@"BIDEditMobilePhoneNumberFirstStepViewController" bundle:nil];
            if(_userBaseInfoDicitonary)
            {
                vc.oldBindingMobilePhoneNumber = [_userBaseInfoDicitonary objectForKey:@"phone"];
            }
            else
            {
                vc.oldBindingMobilePhoneNumber = @"";
            }
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if(row == 2)
        {
            //修改用户昵称
            BIDEditNicknameViewController *vc = [[BIDEditNicknameViewController alloc] initWithNibName:@"BIDEditNicknameViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if(row == 3)
        {
            //修改登录账号
            BIDEditLoginAccountViewController *vc = [[BIDEditLoginAccountViewController alloc] initWithNibName:@"BIDEditLoginAccountViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if(row == 4)
        {
            //修改绑定邮箱
            BIDEditEmailViewController *vc = [[BIDEditEmailViewController alloc] initWithNibName:@"BIDEditEmailViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if(row == 5)
        {
            //修改手势密码
            //BIDLockViewController *lockVC = [[BIDLockViewController alloc] initWithNibName:@"BIDLockViewController" bundle:nil];
            //[self.navigationController pushViewController:lockVC animated:YES];
            BIDGesturePasswordMenuViewController *vc = [[BIDGesturePasswordMenuViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0) return 100.0f;
    else return 44.0f;
}

/**
 *
 */
- (void)tapGestureHandler:(UITapGestureRecognizer*)gestureRecognizer
{
    if([gestureRecognizer.view isKindOfClass:[UIImageView class]])
    {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        UIView *showImgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
        [showImgView setBackgroundColor:[UIColor blackColor]];
        showImgView.userInteractionEnabled  =  YES;
        CGSize imgViewSize = CGSizeMake(screenSize.width, screenSize.width);
        CGRect imgViewFrame = CGRectMake((screenSize.width-imgViewSize.width)/2, (screenSize.height-imgViewSize.height)/2, imgViewSize.width, imgViewSize.height);
        self.oldFrame = imgViewFrame;
        self.largeFrame = CGRectMake(0, 0, 3 * self.oldFrame.size.width, 3 * self.oldFrame.size.height);
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:imgViewFrame];
        imgView.userInteractionEnabled = YES;
        imgView.image = _portraitImg;
        //UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
        //[imgView addGestureRecognizer:pinchGestureRecognizer];
        // add pan gesture
        //UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
        //[imgView addGestureRecognizer:panGestureRecognizer];
        [showImgView addSubview:imgView];
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        [keyWindow addSubview:showImgView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
        [showImgView addGestureRecognizer:tapGesture];
    }
    else if([gestureRecognizer.view isKindOfClass:[UIView class]])
    {
        [gestureRecognizer.view removeFromSuperview];
    }
}

// pinch gesture handler
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = pinchGestureRecognizer.view;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect newFrame = pinchGestureRecognizer.view.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame imgView:(UIImageView*)view];
        [UIView animateWithDuration:0.3f animations:^{
            pinchGestureRecognizer.view.frame = newFrame;
        }];
    }
}
// pan gesture handler
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGSize imgViewSize = CGSizeMake(screenSize.width, screenSize.width);
    CGRect imgViewFrame = CGRectMake((screenSize.width-imgViewSize.width)/2, (screenSize.height-imgViewSize.height)/2, imgViewSize.width, imgViewSize.height);
    UIImageView *view = (UIImageView*)panGestureRecognizer.view;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // calculate accelerator
        CGFloat absCenterX = imgViewFrame.origin.x + imgViewFrame.size.width / 2;
        CGFloat absCenterY = imgViewFrame.origin.y + imgViewFrame.size.height / 2;
        CGFloat scaleRatio = view.frame.size.width / view.frame.size.width;
        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // bounce to original frame
        CGRect newFrame = view.frame;
        newFrame = [self handleBorderOverflow:newFrame imgView:view];
        [UIView animateWithDuration:0.3f animations:^{
            view.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

- (CGRect)handleScaleOverflow:(CGRect)newFrame {
    // bounce to original frame
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width/2, newFrame.origin.y + newFrame.size.height/2);
    if (newFrame.size.width < self.oldFrame.size.width) {
        newFrame = self.oldFrame;
    }
    if (newFrame.size.width > self.largeFrame.size.width) {
        newFrame = self.largeFrame;
    }
    newFrame.origin.x = oriCenter.x - newFrame.size.width/2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height/2;
    return newFrame;
}

- (CGRect)handleBorderOverflow:(CGRect)newFrame imgView:(UIImageView*)imgView
{
    // horizontally
    if (newFrame.origin.x > self.oldFrame.origin.x) newFrame.origin.x = self.oldFrame.origin.x;
    if (CGRectGetMaxX(newFrame) < self.oldFrame.size.width) newFrame.origin.x = self.oldFrame.size.width - newFrame.size.width;
    // vertically
    if (newFrame.origin.y > self.oldFrame.origin.y) newFrame.origin.y = self.oldFrame.origin.y;
    if (CGRectGetMaxY(newFrame) < self.oldFrame.origin.y + self.oldFrame.size.height) {
        newFrame.origin.y = self.oldFrame.origin.y + self.oldFrame.size.height - newFrame.size.height;
    }
    // adapt horizontally rectangle
    if (imgView.frame.size.width > imgView.frame.size.height && newFrame.size.height <= self.oldFrame.size.height) {
        newFrame.origin.y = self.oldFrame.origin.y + (self.oldFrame.size.height - newFrame.size.height) / 2;
    }
    return newFrame;
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerControllerSourceType sourceType;
    BOOL bCanUse = NO;
    if(buttonIndex == 0)
    {
        //从相机
        if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            [BIDCommonMethods showAlertView:@"相机不可用" buttonTitle:@"关闭" delegate:nil tag:0];
        }
        else
        {
            bCanUse = YES;
            sourceType = UIImagePickerControllerSourceTypeCamera;
        }
    }
    else if(buttonIndex == 1)
    {
        //从照片库
        if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            [BIDCommonMethods showAlertView:@"照片库不可用" buttonTitle:@"关闭" delegate:nil tag:0];
        }
        else
        {
            bCanUse = YES;
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
    }
    if(bCanUse)
    {
        UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
        pickerController.delegate = self;
        pickerController.sourceType = sourceType;
        [self presentViewController:pickerController animated:YES completion:^{}];
    }
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:NO completion:^{
        UIImage *originalImg = [info objectForKey:UIImagePickerControllerOriginalImage];
        originalImg = [self imageByScalingToMaxSize:originalImg];
        BIDSetPortraitViewController *setPortraitVC = [[BIDSetPortraitViewController alloc] initWithImage:originalImg];
        setPortraitVC.delegate = self;
        [self presentViewController:setPortraitVC animated:YES completion:^{
        }];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark BIDSetPortraitViewControllerDelegate
/**
 *获取头像图片
 */
- (void)getPortraitImg
{
    //从library中找到设置过的头像图片
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    if(arr.count>0)
    {
        NSString *portraitPath = [arr[0] stringByAppendingPathComponent:@"portraitImg/portrait.png"];
        if([[NSFileManager defaultManager] fileExistsAtPath:portraitPath])
        {
            //文件存在
            _portraitImg = [UIImage imageWithContentsOfFile:portraitPath];
        }
        else
        {
            _portraitImg = [UIImage imageNamed:@"defaultPortrait.png"];
        }
    }
}

#pragma mark
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height)
    {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    }
    else
    {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [UIImage imageCompressForSize:sourceImage targetSize:targetSize];
}

#pragma mark
/**
 *设置图片成功，先校验，然后上传
 */
- (void)finishCropImage:(UIImage *)img viewController:(UIViewController *)viewController
{
    _portraitImg = img;
    //[_myTableView reloadData];
    [viewController dismissViewControllerAnimated:YES completion:^{}];
    //校验
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strCheckURL];
    self.spinnerView.content = @"";
    [self.spinnerView showTheView];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        int rev = [BIDDataCommunication getDataFromNet:strURL toDictionary:dictionary];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinnerView dismissTheView];
            if(rev==1)
            {
                if([[dictionary objectForKey:@"json"] isEqualToString:@"success"])
                {
                    //校验成功，上传头像
                    //上传头像
                    NSDictionary *subDictionary = [dictionary objectForKey:@"data"];
                    [_uploadFile addData:@"sid" value:[subDictionary objectForKey:@"sid"]];
                    [_uploadFile addData:@"checkValue" value:[subDictionary objectForKey:@"checkValue"]];
                    NSData *uploadData = UIImageJPEGRepresentation(_portraitImg, 0.5f);
                    [_uploadFile addFileFromMemory:@"123.jpg" fieldName:@"file" data:uploadData];
                    [_uploadFile finishAddFile];
                    [_uploadFile startUpload];
                }
                else
                {
                    [BIDCommonMethods showAlertView:[dictionary objectForKey:@"message"] buttonTitle:@"关闭" delegate:nil tag:0];
                }
            }
            else
            {
                [BIDCommonMethods showAlertView:@"请求失败" buttonTitle:@"关闭" delegate:nil tag:0];
            }
        });
    });
}

#pragma mark BIDUploadFileDelegate
- (void)uploadFileSuccess
{
    //图片上传成功，则同时也保存到本地
    //保存设置的头像图片
    [_myTableView reloadData];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *urls = [fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask];
    if(urls.count>0)
    {
        NSURL *imgPath = [urls[0] URLByAppendingPathComponent:@"portraitImg" isDirectory:YES];
        BOOL bSuccess = [fileManager createDirectoryAtURL:imgPath withIntermediateDirectories:YES attributes:nil error:nil];
        NSData *imgData = UIImagePNGRepresentation(_portraitImg);
        imgPath = [imgPath URLByAppendingPathComponent:@"portrait.png" isDirectory:NO];
        bSuccess = [imgData writeToURL:imgPath atomically:YES];
    }
    NSArray *arr = self.parentViewController.navigationController.parentViewController.childViewControllers;
    BIDFunctionListViewController *functionListVC = arr[0];
    [functionListVC setPortrait];
}

@end
