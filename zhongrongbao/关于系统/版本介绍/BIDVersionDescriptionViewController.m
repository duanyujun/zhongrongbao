//
//  BIDVersionDescriptionViewController.m
//  zhongrongbao
//
//  Created by mal on 14/11/17.
//  Copyright (c) 2014年 cnsoft. All rights reserved.
//

#import "BIDVersionDescriptionViewController.h"

/**
 *版本介绍
 */
static NSString *strVersionDescription = @"version/queryIntroduction.shtml";

@interface BIDVersionDescriptionViewController ()
{
    IBOutlet UITextView *_versionDescriptionTextView;
}

@end

@implementation BIDVersionDescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"版本介绍";
    
    NSString *strURL = [[NSString alloc] initWithFormat:@"%@/%@", [BIDAppDelegate getServerAddr], strVersionDescription];
    NSString *strCurrentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    strCurrentVersion = [[NSString alloc] initWithFormat:@"V%@", strCurrentVersion];
    NSString *strPost = [[NSString alloc] initWithFormat:@"jsonDataSet={\"vType\":\"02\", \"versionId\":\"%@\"}", strCurrentVersion];
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
                    NSDictionary *subDictionary = [dictionary objectForKey:@"data"];
                    NSString *strVersion = [subDictionary objectForKey:@"verIntr"];
                    _versionDescriptionTextView.text = [BIDCommonMethods filterHTML:strVersion];
                }
            }
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
