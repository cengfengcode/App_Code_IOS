//
//  LocationMapViewController.m
//  MyChat
//
//  Created by 层峰建材科技有限公司 on 16/9/21.
//  Copyright © 2016年 沈家林. All rights reserved.
//

#import "LocationMapViewController.h"
#import <MapKit/MapKit.h>
#import "LOAnnotation.h"

@interface LocationMapViewController ()<MKMapViewDelegate>

//地图
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

//定位
@property (nonatomic, strong) CLLocationManager *locationManager;

//记录最新点的位置
@property (nonatomic, assign) CGPoint lastPoint;

//划线的时候需要使用地理位置编码
@property (nonatomic, strong) CLGeocoder *geocoder;





@end

@implementation LocationMapViewController
- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 在 info.plist 文件中设置支持定位的字段(影响到"设置"中"隐私"的"定位服务"中的内容)
    // 可通过先后的设置对比查看
    //NSLocationWhenInUseUsageDescription
    //NSLocationAlwaysUsageDescription

    //左边
//    UIBarButtonItem *lbbItem = [[UIBarButtonItem alloc] initWithTitle:@"移除所有大头针" style:UIBarButtonItemStyleDone target:self action:@selector(removeAllPin:)];
//    self.navigationItem.leftBarButtonItem = lbbItem;

    //右边划线
    UIBarButtonItem *rbbItem = [[UIBarButtonItem alloc] initWithTitle:@"画路线" style:UIBarButtonItemStyleDone target:self action:@selector(drawLine:)];
    self.navigationItem.rightBarButtonItem = rbbItem;

    //添加长按开始手势,方法中实现添加大头针
    UILongPressGestureRecognizer *longPreGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addPinView:)];
    [self.mapView addGestureRecognizer:longPreGes];

    //设置代理
    self.mapView.delegate = self;

    // 判断用户定位服务有没有打开
    if (![CLLocationManager locationServicesEnabled]) {
        // 用户定位服务没有打开
        NSLog(@"您的设置中定位服务没有打开");
        // 跳转到手机中的设计界面
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
        return;
    }
    // 判断用户的授权状态
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        // 请求用户授权
        [self.locationManager requestWhenInUseAuthorization];
    }
    //让地图显示到用户当前的位置
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    //设置地图类型
    /**
     * MKMapTypeStandard 普通地图
     * MKMapTypeSatellite 卫星云图
     * MKMapTypeHybrid 普通地图覆盖于卫星云图之上
     * MKMapTypeSatelliteFlyover 地形和建筑物的三维模型
     * MKMapTypeHybridFlyover 显示道路和附加元素的Flyover
     */
    self.mapView.mapType = MKMapTypeStandard;
    // Do any additional setup after loading the view from its nib.
}

//定位按钮
- (IBAction)myLocationAction:(UIButton *)sender {
    //定位用户当前位置,并放大
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;

}

//更新用户轨迹,内部含有 location 参数的用户位置
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    self.location = userLocation.location;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ---- MKMapViewDelegate
//这个方法就是地图控件根据标注信息模型创建大头针视图的方法
- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {

    //标准做法
    if ([annotation isKindOfClass:[LOAnnotation class]]) {
        static NSString *identifier = @"view";
        MKPinAnnotationView *view = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (view == nil) {
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        }
        //view赋值
        view.annotation = annotation;
        //温馨的提醒来喽，此时运行，你会发现大头针的提示不会出现。系统默认的属性是NO
        // 设置是否弹出标注
        view.canShowCallout = YES;
        //标注偏移
        view.calloutOffset = CGPointZero;
        view.draggable = NO;
        //是否从头而降
        view.animatesDrop = YES;
        //设置大头针的颜色
//        view.pinTintColor = [UIColor greenColor];
        //设置弹框
        view.canShowCallout = YES;
        //在弹框中添加图片
        UIImageView *leftImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic1.jpg"]];
        leftImg.frame = CGRectMake(0, 0, 44, 44);
        view.leftCalloutAccessoryView = leftImg;
        UIImageView *rightImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tx.jpeg"]];
        rightImg.frame = CGRectMake(0, 0, 44, 44);
        view.rightCalloutAccessoryView = rightImg;
        return view;
    }
    return nil;
}

- (void)addPinView:(UITapGestureRecognizer *)sender {
    //添加大头针视图,不需要我们处理, 我们只需要添加大头针标注(我们创建的标注模型 LOAnnotation), 系统就帮我们添加大头针
    if (sender.state == UIGestureRecognizerStateBegan) {
//判断长按手势是开始按压

    //获取点击的 x,y 的值
    CGPoint point = [sender locationInView:self.mapView];
    // 同一位置时, 不再添加大头针
    if (self.lastPoint.x == point.x && self.lastPoint.y == point.y) {
        return;
    }
    //根据 x,y 坐标点,获得经纬度信息
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
    //创建标注模型对象
    LOAnnotation *annotation = [[LOAnnotation alloc] init];
    //给 annotation 属性赋值
    annotation.coordinate = coordinate;
    annotation.title = [NSString stringWithFormat:@"%f,%f", coordinate.longitude, coordinate.latitude];
    annotation.subtitle = @"1016河南层峰建材";
    //添加大头针标注信息
    [self.mapView addAnnotation:annotation];
    //记录最新的位置
    self.lastPoint = point;
    }
}

//移除所有大头针
- (void)removeAllPin:(UIBarButtonItem *)sender {
    //不用我们移除大头针视图, 只需要我们把大头针视图的标注模型删除就可以了
    //移除所有大头针
    [self.mapView removeAnnotations:self.mapView.annotations];
    //移除单个大头针
    //    self.mapView removeAnnotation:<#(nonnull id<MKAnnotation>)#>];
}

//画路线
- (void)drawLine:(UIBarButtonItem *)sender {

#if 1
    //起点

    [self.geocoder reverseGeocodeLocation:self.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *sourcePlacemark; sourcePlacemark = [placemarks firstObject];
        //终点
        //根据 x,y 坐标点,获得经纬度信息
        NSLog(@"图上点的坐标:%f-%f", self.lastPoint.x,self.lastPoint.y);
            CLLocationCoordinate2D coordinate = [self.mapView convertPoint:self.lastPoint toCoordinateFromView:self.mapView];

        CLLocation *destinaLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [self.geocoder reverseGeocodeLocation:destinaLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            CLPlacemark *destinaPlacemark = [placemarks firstObject];
//            [self addLineFromPlacemark:sourcePlacemark toPlacemark:destinaPlacemark];


#if 1
            //在起始位置添加大头针
            LOAnnotation *sourceAN = [[LOAnnotation alloc] init];
            sourceAN.coordinate = self.location.coordinate;
            [self.mapView addAnnotation:sourceAN];
            //在目的位置添加大头针
            LOAnnotation *desAN = [[LOAnnotation alloc] init];
            desAN.coordinate = coordinate;
            [self.mapView addAnnotation:desAN];
            MKPlacemark *startPlace = [[MKPlacemark alloc] initWithCoordinate:self.location.coordinate addressDictionary:nil];
            MKPlacemark *endPlace = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
            MKMapItem *startItem = [[MKMapItem alloc] initWithPlacemark:startPlace];
            MKMapItem *endItem = [[MKMapItem alloc] initWithPlacemark:endPlace];
            //线路请求
            MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
            request.source = startItem;
            request.destination = endItem;
            //发送请求
            MKDirections *dirs = [[MKDirections alloc] initWithRequest:request];
            //处理路线
            [dirs calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
                NSLog(@"共有 %lu 条线路", response.routes.count);
                //添加 轨迹点模型, 它不是轨迹, 轨迹是 MKPolygonView, 而 polyline 是轨迹模型(类似于大头针标注模型 与大头针视图)
                for (MKRoute *route in response.routes) {
                    [self.mapView addOverlay:route.polyline];
                }
            }];
#endif


            NSLog(@"1,路线起始位置经纬度:%f-%f////%f-%f", sourcePlacemark.location.coordinate.latitude,sourcePlacemark.location.coordinate.longitude,destinaPlacemark.location.coordinate.latitude,destinaPlacemark.location.coordinate.longitude);
        }];
    }];




#endif
}

#pragma mark ---- 自己封装方法, 实现画路线方法
- (void)drawLineBetweenCity:(NSString *)sourceCityName toDestinationCity:(NSString *)desCityName {
    //因为传入的是 地址字符串, 所以需要进行正向地理编码 获取地理位置信息
    [self.geocoder geocodeAddressString:sourceCityName completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        //获取地标对象
        CLPlacemark *sourcePlacemark = [placemarks firstObject];
        //设置显示范围
        [self.mapView setRegion:MKCoordinateRegionMake(sourcePlacemark.location.coordinate, MKCoordinateSpanMake(10.0, 10.0)) animated:YES];
        //地理编码一次只能定位到一个位置, 不能同时定位, 所以放在第一个位置定位完成之后, 再次定位另一个地理位置
        [self.geocoder geocodeAddressString:desCityName completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            //获取地标对象
            CLPlacemark *desPlace = [placemarks firstObject];
            [self addLineFromPlacemark:sourcePlacemark toPlacemark:desPlace];
        }];
    }];
}

- (void)addLineFromPlacemark:(CLPlacemark *)fromPM toPlacemark:(CLPlacemark *)toPM {
    //在起始位置添加大头针
    LOAnnotation *sourceAN = [[LOAnnotation alloc] init];
    sourceAN.coordinate = fromPM.location.coordinate;
    [self.mapView addAnnotation:sourceAN];
    //在目的位置添加大头针
    LOAnnotation *desAN = [[LOAnnotation alloc] init];
    desAN.coordinate = toPM.location.coordinate;
    [self.mapView addAnnotation:desAN];
    //设置路线请求
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    //设置路线类型
    /*
     MKDirectionsTransportTypeAutomobile 自驾
     MKDirectionsTransportTypeWalking 步行
     MKDirectionsTransportTypeTransit 公交
     */
    request.transportType = MKDirectionsTransportTypeWalking;
    //设置路线的起点和终点
    MKPlacemark *sourcePlace = [[MKPlacemark alloc] initWithPlacemark:fromPM];
    request.source = [[MKMapItem alloc] initWithPlacemark:sourcePlace];
    MKPlacemark *desPlace = [[MKPlacemark alloc] initWithPlacemark:toPM];
    request.destination = [[MKMapItem alloc] initWithPlacemark:desPlace];
    NSLog(@"2,路线起始位置经纬度:起点%f-%f////终点%f-%f", fromPM.location.coordinate.latitude,fromPM.location.coordinate.longitude,toPM.location.coordinate.latitude,toPM.location.coordinate.longitude);
    //根据路线请求对象获取路线对象(因为具体两点的位置需要向服务器请求数据)
    MKDirections *dirs = [[MKDirections alloc] initWithRequest:request];
    //处理路线
    [dirs calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"共有 %lu 条线路", response.routes.count);
        //添加 轨迹点模型, 它不是轨迹, 轨迹是 MKPolygonView, 而 polyline 是轨迹模型(类似于大头针标注模型 与大头针视图)
        for (MKRoute *route in response.routes) {
            [self.mapView addOverlay:route.polyline];
        }
    }];
}

#pragma mark ---- 系统的 绘制路线的方法
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer *render = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    //设置线路的颜色
    render.strokeColor = [UIColor greenColor];
    return render;
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
