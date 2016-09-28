//
//  ChatTabBarViewController.m
//  MyChat
//
//  Created by 沈家 on 16/5/9.
//  Copyright © 2016年 沈家林. All rights reserved.
//

#import "ChatTabBarViewController.h"

#define KChatTabBarClass @"KChatTabBarClass"
#define KChatTabBarTitle @"KChatTabBarTitle"
#define KChatTabBarImage @"KChatTabBarImage"
#define KChatTabBarSelImage @"KChatTabBarSelImage"


@interface ChatTabBarViewController ()

@end

@implementation ChatTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *array=@[
                     @{KChatTabBarClass:@"ConversationListController",
                       KChatTabBarTitle:@"会话",
                       KChatTabBarImage:@"tabbar_mainframe",
                       KChatTabBarSelImage:@"tabbar_mainframeHL"},
                     @{KChatTabBarClass:@"ContactListViewController",
                       KChatTabBarTitle:@"通讯录",
                       KChatTabBarImage:@"tabbar_me",
                       KChatTabBarSelImage:@"tabbar_meHL"}
                     ,
                     @{KChatTabBarClass:@"DecorationViewController",
                       KChatTabBarTitle:@"装饰",
                       KChatTabBarImage:@"ScanStreet",
                       KChatTabBarSelImage:@"ScanStreet_HL"}
                     ,
                     @{KChatTabBarClass:@"JobViewController",
                       KChatTabBarTitle:@"工作",
                       KChatTabBarImage:@"ScanBook",
                       KChatTabBarSelImage:@"ScanBook_HL"}
                     ,
                     @{KChatTabBarClass:@"JobViewController",
                       KChatTabBarTitle:@"我的",
                       KChatTabBarImage:@"ScanBook",
                       KChatTabBarSelImage:@"ScanBook_HL"}
                     ];
    NSMutableArray *viewcontrollers=[NSMutableArray new];
    for (NSInteger i=0; i<array.count; i++) {
        UIViewController *vc=[NSClassFromString(array[i][KChatTabBarClass]) new];
        UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:vc];
        vc.title=array[i][KChatTabBarTitle];
        nav.tabBarItem.image=[[UIImage imageNamed:array[i][KChatTabBarImage]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIImage *selImage=[UIImage imageNamed:array[i][KChatTabBarSelImage]];
        //imageWithRenderingMode: 设置渲染样式
        //UIImageRenderingModeAlwaysOriginal 才用原始图片，不做渲染
        nav.tabBarItem.selectedImage=[selImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        nav.navigationBar.barTintColor = [UIColor colorWithRed:29/255.0f green:186/255.0f blue:156/255.0f alpha:1];
        //渲染色
        self.tabBar.tintColor=KColorRGB(14, 179, 0);
        [viewcontrollers addObject:nav];
    }
    self.viewControllers=viewcontrollers;

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
