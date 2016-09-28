//
//  DecorationViewController.m
//  MyChat
//
//  Created by 层峰建材科技有限公司 on 16/9/20.
//  Copyright © 2016年 沈家林. All rights reserved.
//

#import "DecorationViewController.h"

@interface DecorationViewController ()

@end

@implementation DecorationViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //改变导航栏的颜色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:29/255.0f green:186/255.0f blue:156/255.0f alpha:1];
    [self.myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.runoob.com/html/html5-intro.html"]]];
    // Do any additional setup after loading the view from its nib.
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
