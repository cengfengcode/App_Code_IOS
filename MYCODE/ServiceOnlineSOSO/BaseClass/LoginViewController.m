//
//  LoginViewController.m
//  MyChat1525
//
//  Created by 沈家林 on 16/4/1.
//  Copyright © 2016年 沈家林. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()<UITextFieldDelegate>
{
    UITextField *_accountTextField;
    UITextField *_passwordTextField;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configUI];
}

-(void)configUI{
    self.view.backgroundColor=[UIColor whiteColor];
    KWS(ws);
    NSArray *labelNames=@[@"账户：",@"密码："];
    for (NSInteger i=0; i<labelNames.count; i++) {
        UILabel *label=[UILabel new];
        label.text=labelNames[i];
        label.font=[UIFont systemFontOfSize:15];
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(ws.view).offset(30);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(80);
            make.top.equalTo(ws.view).offset(80+50*i);
        }];
    }
    _accountTextField=[UITextField new];
    _accountTextField.placeholder=@"请输入账户";
    _accountTextField.borderStyle=UITextBorderStyleRoundedRect;
    _accountTextField.returnKeyType=UIReturnKeyNext;
    _accountTextField.delegate=self;
    [self.view addSubview:_accountTextField];
    [_accountTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ws.view).offset(110);
        make.height.mas_equalTo(30);
        make.right.equalTo(ws.view).offset(-30);
        make.top.equalTo(ws.view).offset(80);
    }];
    [_accountTextField becomeFirstResponder];
    
    _passwordTextField=[UITextField new];
    _passwordTextField.placeholder=@"请输入密码";
    _passwordTextField.borderStyle=UITextBorderStyleRoundedRect;
    _passwordTextField.returnKeyType=UIReturnKeyDone;
    _passwordTextField.delegate=self;
    [self.view addSubview:_passwordTextField];
    [_passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ws.view).offset(110);
        make.height.mas_equalTo(30);
        make.right.equalTo(ws.view).offset(-30);
        make.top.equalTo(ws.view).offset(130);
    }];
    
    NSArray *btnNames=@[@"登录",@"注册"];
    for (NSInteger i=0; i<btnNames.count; i++) {
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeSystem];
        [btn setTitle:btnNames[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btcClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag=100+i;
        [self.view addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            if (i==0) {
                make.left.equalTo(ws.view).offset(30);
            }else{
                make.right.equalTo(ws.view).offset(-30);
            }
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(80);
            make.top.equalTo(ws.view).offset(200);
        }];
    }
    
}

-(void)btcClick:(UIButton *)btn{
    if (btn.tag==100) {
        [self login];
    }else if(btn.tag==101){
        [self regist];
    }
}

-(void)login{
    if (_accountTextField.text.length==0||_passwordTextField.text.length==0) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //登录....
        EMError *error = [[EMClient sharedClient] loginWithUsername:_accountTextField.text password:_passwordTextField.text];
        if (!error)
        {
            /*设置是否自动登录
             自动登录失效的情况：
             用户调用了SDK的登出动作;
             用户在别的设备上更改了密码, 导致此设备上自动登陆失败;
             用户的账号被从服务器端删除;
             用户从另一个设备登录，把当前设备上登陆的用户踢出.
             */
            [[EMClient sharedClient].options setIsAutoLogin:YES];
            
            //将聊天记录从数据库中取出来
            [[EMClient sharedClient].chatManager loadAllConversationsFromDB];
            dispatch_async(dispatch_get_main_queue(), ^{
                //发通知
                [[NSNotificationCenter defaultCenter] postNotificationName:KNotChangeRoot object:nil userInfo:@{@"root":@"tabbar"}];
            });
        }
        
    });

}

-(void)regist{
    if (_accountTextField.text.length==0||_passwordTextField.text.length==0) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //注册，点进去看详细注释
        EMError *error = [[EMClient sharedClient] registerWithUsername:_accountTextField.text password:_passwordTextField.text];
        if (error==nil) {
            NSLog(@"注册成功");
            [self login];
        }
    });
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


#pragma mark textFeildDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField==_accountTextField) {
        [_accountTextField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
    }else if(textField==_passwordTextField){
        [self login];
    }
    return YES;
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
