//
//  ViewController.m
//  TJSelectorDemo
//
//  Created by TanJian on 16/6/15.
//  Copyright © 2016年 Joshpell. All rights reserved.
//

#import "ViewController.h"
#import "TJAdressView.h"

#define kDeviceWidth  [UIScreen mainScreen].bounds.size.width
#define kDeviceHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@property(nonatomic,strong)TJAdressView *selector;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *cityArr = @[@{@"name":@"东城区",@"id":@"1"},@{@"name":@"朝阳区",@"id":@"2"}];
    NSDictionary *dataDict = @{@"name":@"北京",@"id":@"11",@"citys":cityArr};
    
    NSArray *cityArr1 = @[@{@"name":@"江北区",@"id":@"1"},@{@"name":@"渝中区",@"id":@"2"},@{@"name":@"沙坪坝区",@"id":@"3"}];
    NSDictionary *dataDict1 = @{@"name":@"重庆",@"id":@"12",@"citys":cityArr1};
    
    self.selector.provinceDataArr = [NSMutableArray arrayWithArray:@[dataDict,dataDict1,dataDict,dataDict1,dataDict]];
    [self.view addSubview:_selector];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(TJAdressView *)selector{
    if (!_selector) {
        _selector = [[TJAdressView alloc]initWithFrame:CGRectMake(0, 0, kDeviceWidth, kDeviceHeight)];
        _selector.superVC = self;
    }
    return _selector;
}

@end
