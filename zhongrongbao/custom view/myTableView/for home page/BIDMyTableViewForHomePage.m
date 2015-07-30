//
//  BIDMyTableViewForHomePage.m
//  zhongrongbao
//
//  Created by mal on 15/6/30.
//  Copyright (c) 2015年 cnsoft. All rights reserved.
//

#import "BIDMyTableViewForHomePage.h"

@implementation BIDMyTableViewForHomePage
@synthesize param1;
@synthesize param2;

- (void)commonLoadDataForPage
{
    if(self.bLoadFirstPageData && !_pullDownRefreshing)
    {
        [self.spinnerView showTheView];
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *strPost = [self getPostData];
        strPost = [[NSString alloc] initWithFormat:@"dataMsg=%@", strPost];
        int value = [BIDDataCommunication uploadDataByPostWithoutCookie:self.strURL postValue:strPost curPage:self.pageNumber toArr:self.itemsArr];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.bLoadFirstPageData)
            {
                self.bLoadFirstPageData = NO;
                if(!_pullDownRefreshing)
                {
                    [self.spinnerView dismissTheView];
                }
                else
                {
                    // _pullDownRefreshLabel.text = @"下拉刷新";
                    [_pullDownRefreshSpinner stopAnimating];
                    _pullDownRefreshing = NO;
                    [self setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                }
            }
            [self loadDataComplete];
            //成功
            if(value==1)
            {
                [self reloadData];
                //告知tableView所在viewcontroller数据源发生了改变，该方法可选
                [self.myDelegate updateDataSource:self.itemsArr];
                //
                if(self.itemsArr.count<self.pageNumber*[BIDDataCommunication getCountPerPage])
                {
                    self.bHasMore = NO;
                    self.pageNumber==1?1:self.pageNumber--;
                }
            }
            else
            {
                self.pageNumber==1?1:self.pageNumber--;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"加载失败" delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
                [alert show];
            }
        });
    });
}
/**
 *  {"Head":{"channelType":"04","interfaceVersion":"1.0","funCode":"mobileIndex","sid":"6DB3C83DFCBCA9D2E1B56827BC435F3A"},"Body":{"pageInfo":{"pageNum": "13" },"param":{"group":"enterprise","sort":"02"}}}
 */
- (NSString*)getPostData
{
    NSString *strPost = @"";
    NSDictionary *headDictionary = @{@"channelType":@"05", @"interfaceVersion":@"1.0", @"funCode":@"mobileIndex", @"sid":@"6DB3C83DFCBCA9D2E1B56827BC435F3A"};
    NSString *strPageNum = [[NSString alloc] initWithFormat:@"%d", self.pageNumber];
    NSDictionary *bodyDictionary = @{@"pageInfo":@{@"pageNum":strPageNum}, @"param":@{@"group":param1, @"sort":param2}};
    NSDictionary *integratedDictionary = @{@"Head":headDictionary, @"Body":bodyDictionary};
    NSError *err;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:integratedDictionary options:kNilOptions error:&err];
    strPost = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    return strPost;
}

@end
