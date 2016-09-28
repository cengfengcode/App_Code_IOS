//
//  LOAnnotation.h
//  LessonMKMapView
//
//  Created by lanouhn on 16/6/16.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

//iOS 没有定义一个基类实现这个协议, 供开发者使用, 原因是 MKAnnotation 是一个模型对象, 对于多数应用来说, 使用的模型可能会各不相同, 开发者可以根据需求在该(MKAnnotation)模型的基础上添加其他属性.
//创建出来的模型, 只需要遵守 MKAnnotation 协议就会变成标注模型
@interface LOAnnotation : NSObject <MKAnnotation>
//遵守完协议之后, 还需要声明以下三个属性
//标注位置
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
//标题
@property (nonatomic, copy) NSString *title;
//子标题
@property (nonatomic, copy) NSString *subtitle;



@end
