//
//  Define.h
//  ServiceOnlineSOSO
//
//  Created by 层峰建材科技有限公司 on 16/9/27.
//  Copyright © 2016年 层峰建材科技有限公司. All rights reserved.
//

#ifndef Define_h
#define Define_h

#pragma mark 系统相关
#define KWS(ws) __weak typeof(&*self) ws=self
//屏幕宽
#define KScreenWidth [UIScreen mainScreen].bounds.size.width
//屏幕高
#define KScreenHeight [UIScreen mainScreen].bounds.size.height

#pragma mark 颜色相关
#define KColorRGBA(r,g,b,a)  [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:b/255.0 alpha:a]
#define KColorRGB(r,g,b)  KColorRGBA(r,g,b,1)
#define KColorNameLabelText KColorRGB(54,71,121)

#pragma mark 通知中心
#define KNotChangeRoot @"KNotChangeRoot" //改变根视图

//打印 API
#define KMyLog(...) NSLog(__VA_ARGS__)

#endif /* Define_h */
