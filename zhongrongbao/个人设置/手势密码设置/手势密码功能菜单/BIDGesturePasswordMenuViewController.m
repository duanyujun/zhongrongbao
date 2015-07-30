//
//  BIDGesturePasswordMenuViewController.m
//  zhongrongbao
//
//  Created by mal on 14/10/30.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDGesturePasswordMenuViewController.h"
#import "BIDCommonMethods.h"
#import "BIDLockViewController.h"

@interface BIDGesturePasswordMenuViewController ()

@end

@implementation BIDGesturePasswordMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"手势密码设置";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnHandler)];
    [self.view setBackgroundColor:[UIColor colorWithRed:236.0f/255.0f green:240.0f/255.0f blue:241.0f/255.0f alpha:1.0f]];
    UIView *footerView = [[UIView alloc] init];
    self.tableView.tableFooterView = footerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backBtnHandler
{
    [self.navigationController popViewControllerAnimated:YES];
}

//UISwitch事件
- (void)switchChangeValueHandler:(UISwitch*)mySwitch
{
    NSNumber *flagValue = @0;
    NSString *strConfigPath = [BIDCommonMethods getConfigPath];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:strConfigPath];
    if(mySwitch.on)
    {
        flagValue = @1;
        [dictionary setValue:@1 forKey:@"gesturePasswordState"];
    }
    else
    {
        flagValue = @0;
        [dictionary setValue:@0 forKey:@"gesturePasswordState"];
    }
    [dictionary writeToFile:strConfigPath atomically:YES];
    
    //
    NSArray *docsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *strDocPath = docsArr[0];
    NSString *strLoginInfoPath = [[NSString alloc] initWithFormat:@"%@", [strDocPath stringByAppendingPathComponent:loginInfoFileName]];
    if([[NSFileManager defaultManager] fileExistsAtPath:strLoginInfoPath])
    {
        NSMutableArray *arr = [[NSMutableArray alloc] initWithContentsOfFile:strLoginInfoPath];
        NSString *strUserId = [BIDAppDelegate getUserId];
        for(int i=0; i<arr.count; i++)
        {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithDictionary:arr[i]];
            if([[dictionary objectForKey:@"uid"] isEqualToString:strUserId])
            {
                [dictionary setValue:flagValue forKey:@"flag"];
                [arr replaceObjectAtIndex:i withObject:dictionary];
                break;
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //开启密码锁定，重置手势密码
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier1 = @"identifier1";
    static NSString *identifier2 = @"identifier2";
    UITableViewCell *cell = nil;
    NSUInteger section = indexPath.section;
    if(section==0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier1];
        }
        UISwitch *mySwitch = [[UISwitch alloc] init];
        [mySwitch addTarget:self action:@selector(switchChangeValueHandler:) forControlEvents:UIControlEventValueChanged];
        CGRect switchFrame = mySwitch.frame;
        switchFrame.origin.x = CGRectGetWidth(self.view.frame)-15-CGRectGetWidth(switchFrame);
        switchFrame.origin.y = (44-CGRectGetHeight(switchFrame))/2;
        mySwitch.frame = switchFrame;
        NSString *strConfigPath = [BIDCommonMethods getConfigPath];
        NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:strConfigPath];
        NSNumber *value = [dictionary objectForKey:@"gesturePasswordState"];
        if([value intValue]==1)
        {
            mySwitch.on = YES;
        }
        else
        {
            mySwitch.on = NO;
        }
        [cell.contentView addSubview:mySwitch];
        cell.textLabel.text = @"开启密码锁定";
    }
    else if(section==1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier2];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier2];
        }
        cell.textLabel.text = @"重置手势密码";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [cell setBackgroundColor:[UIColor whiteColor]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSUInteger section = indexPath.section;
    if(section==0)
    {}
    else if(section==1)
    {
        BIDLockViewController *lockVC = [[BIDLockViewController alloc] initWithNibName:@"BIDLockViewController" bundle:nil];
        [self.navigationController pushViewController:lockVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

@end
