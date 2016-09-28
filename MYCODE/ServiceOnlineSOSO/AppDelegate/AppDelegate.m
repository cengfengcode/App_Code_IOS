//
//  AppDelegate.m
//  ServiceOnlineSOSO
//
//  Created by 层峰建材科技有限公司 on 16/9/27.
//  Copyright © 2016年 层峰建材科技有限公司. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "ChatTabBarViewController.h"
#import "EaseUI.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor=[UIColor clearColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRoot:) name:KNotChangeRoot object:nil];
    [[EaseSDKHelper shareHelper] easemobApplication:application
                      didFinishLaunchingWithOptions:launchOptions
                                             appkey:@"hncjliyingjie#serviceonline"//
                                       apnsCertName:nil
                                        otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    //    self.window.rootViewController=[LoginViewController new];
    //获得自动登录的结果
    BOOL isAutoLogin = [EMClient sharedClient].options.isAutoLogin;
    if (isAutoLogin) {
        self.window.rootViewController=[ChatTabBarViewController new];
    }else{
        self.window.rootViewController=[LoginViewController new];

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请使用测试账号为1234，密码是1234" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }

    [self setTop];





    [self.window makeKeyAndVisible];
    return YES;
    // Override point for customization after application launch.
    return YES;
}

-(void)changeRoot:(NSNotification *)not{
    NSString *root=not.userInfo[@"root"];
    if ([root isEqualToString:@"login"]) {
        self.window.rootViewController=[LoginViewController new];
    }else if([root isEqualToString:@"tabbar"]){
        self.window.rootViewController=[ChatTabBarViewController new];
    }
}



-(void)setTop{
    //设置状态栏的字体颜色
    /*
     UIStatusBarStyleDefault 默认状态 字体是黑色 适用于背景是浅色调
     UIStatusBarStyleLightContent 字体是白色 适用于背景是深色调
     */
    [UIApplication sharedApplication].statusBarStyle=UIStatusBarStyleLightContent;

    //只要出现UINavigationBar，自己不去修改的情况下就是下面设置的样式
    UINavigationBar *navigationBar=[UINavigationBar appearance];
    //设置navigationBar的颜色
    navigationBar.barTintColor=[UIColor blackColor];
    //设置navigationBar的渲染色
    navigationBar.tintColor=[UIColor whiteColor];
    /*设置navigationBar的title的属性
     NSForegroundColorAttributeName 设置字体颜色
     NSFontAttributeName 设置字体的font
     */
    navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor whiteColor]};

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
