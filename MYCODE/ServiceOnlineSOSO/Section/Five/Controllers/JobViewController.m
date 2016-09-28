//
//  JobViewController.m
//  MyChat
//
//  Created by 层峰建材科技有限公司 on 16/9/20.
//  Copyright © 2016年 沈家林. All rights reserved.
//

#import "JobViewController.h"
//包含 CL 开头的类, 如 定位类 和 地理编码类
#import <CoreLocation/CoreLocation.h>

#import "LocationMapViewController.h"

@interface JobViewController ()<CLLocationManagerDelegate>

//CLLocationManager 专门负责定位的一个类
@property (nonatomic, strong) CLLocationManager *locationManager;

//CLGeocoder 专门负责地理位置编码的类(无论是正向,还是反向都用此类)
@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic, strong) CLLocation *location;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;

@end

@implementation JobViewController

- (CLLocation *)location {
    if (!_location) {
        self.location = [[CLLocation alloc] init];
    }
    return _location;
}

- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //改变导航栏的颜色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:29/255.0f green:186/255.0f blue:156/255.0f alpha:1];

    UIBarButtonItem *lbbItem = [[UIBarButtonItem alloc] initWithTitle:@"定位" style:UIBarButtonItemStyleDone target:self action:@selector(locationBarButAction:)];
    self.navigationItem.leftBarButtonItem = lbbItem;

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationBarButAction:(UIBarButtonItem *)sender {
    LocationMapViewController *locationMapVC = [[LocationMapViewController alloc] init];
    locationMapVC.location = self.location;
    [self.navigationController pushViewController:locationMapVC animated:YES];
}

//定位按钮
- (IBAction)locationAction:(UIButton *)sender {
#if 1
    self.locationManager = [[CLLocationManager alloc] init];
    if (![CLLocationManager locationServicesEnabled]) {
        //用户定位信息没有打开
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"定位服务未打开" message:@"请打开您的定位服务" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        }];
         UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
             [[UIApplication sharedApplication] openURL:url];
         }];
        [alertCon addAction:cancleAction];
        [alertCon addAction:confirmAction];
        [self presentViewController:alertCon animated:YES completion:nil];
        return;
    }
    //判断用户的授权状态
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        //请求用户授权
        [self.locationManager requestWhenInUseAuthorization];
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        //设置代理
        self.locationManager.delegate = self;
        //设置定位准确度
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //开始定位
        [self.locationManager startUpdatingLocation];
    }

#endif
#if 0
    //创建一个定位管理对象
    self.locationManager = [[CLLocationManager alloc] init];
    //判断用户定位服务是否打开
    if (![CLLocationManager locationServicesEnabled]) {
        //用户定位信息没有打开
        NSLog(@"您的设置中定位服务没有打开");
        //跳转手机中的设置界面
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
        return;
    }
    /*
     iOS 7 之后, 苹果在保护用户隐私方面做了很大的加强, 以下操作必须经过用户授权:
     1, 要想获得用户的位置, 访问用户的相机, 访问相册, 访问通讯录, 访问日历等都需要用户手动授权
     2, 当想访问用户以上的隐私信息时, 系统会自动弹出一个对话框让用户授权
     */
    //判断用户的授权状态
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        //请求用户授权
        [self.locationManager requestWhenInUseAuthorization];
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //设置代理
        self.locationManager.delegate = self;
        //设置定位准确(越精确, 越耗电)
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        /*
         最佳导航
         kCLLocationAccuracyBestForNavigation;
         最精准
         kCLLocationAccuracyBest;
         十米误差
         kCLLocationAccuracyNearestTenMeters;
         百米误差
         kCLLocationAccuracyHundredMeters;
         千米误差
         kCLLocationAccuracyKilometer;
         三千米误差
         kCLLocationAccuracyThreeKilometers;
         */
        //设置定位频率, 每隔多少米定位一次
        //        self.locationManager.distanceFilter = 10.0;//十米定位一次

        //开始定位
        [self.locationManager startUpdatingLocation];
    }
#endif


}

#pragma mark -- CLLocationManagerDelegate 定位
//定位失败时触发这个方法
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"定位失败:%@", error);
}

//定位成功
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {

    //取出一个位置对象
    self.location = [locations firstObject];
    CLLocationCoordinate2D coordinate = self.location.coordinate;
    self.longitudeLabel.text = [NSString stringWithFormat:@"%f", coordinate.longitude];
    self.latitudeLabel.text = [NSString stringWithFormat:@"%f", coordinate.latitude];
    NSLog(@"%f,%f", coordinate.longitude, coordinate.latitude);
    [self.locationManager stopUpdatingLocation];

}
//正向地理编码, 根据地质获取经纬度信息

//反向地理编码
- (IBAction)recodeAction:(UIButton *)sender {
    //反地理编码

    CLLocation *location = self.location;
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark=[placemarks firstObject];
        NSLog(@"详细信息:%@",placemark.addressDictionary);
        self.locationNameLabel.text = [NSString stringWithFormat:@"%@-%@-%@-%@-%@-%@-%@-%@-%@-%@", placemark.addressDictionary[@"City"], placemark.addressDictionary[@"Country"], placemark.addressDictionary[@"CountryCode"], placemark.addressDictionary[@"FormattedAddressLines"][0], placemark.addressDictionary[@"Name"], placemark.addressDictionary[@"State"], placemark.addressDictionary[@"Street"], placemark.addressDictionary[@"SubLocality"], placemark.addressDictionary[@"Thoroughfare"], placemark.addressDictionary[@"City"]];

    }];
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
