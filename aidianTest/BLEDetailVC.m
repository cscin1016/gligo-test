//
//  BLEDetailVC.m
//  aidianTest
//
//  Created by 陈双超 on 2019/5/8.
//  Copyright © 2019 陈双超. All rights reserved.
//

#import "BLEDetailVC.h"
#import "BLEDataModel.h"
#import "BLEManager.h"

@interface BLEDetailVC ()
@property (weak, nonatomic) IBOutlet UILabel *connectStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceVersionLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *chargeStatus;
@property (weak, nonatomic) IBOutlet UILabel *chargePercent;
@property (weak, nonatomic) IBOutlet UILabel *stepStatus;
@property (weak, nonatomic) IBOutlet UILabel *stepNumber;
@property (weak, nonatomic) IBOutlet UILabel *hardVersion;

@end

@implementation BLEDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RefreshDetailDataAction:) name:@"RefreshBLEDetailData" object:nil];
}

- (IBAction)reCheckAction:(UIButton *)sender {
    [self initViewToResearch];
    [[BLEManager sharedManager] sendChekCommand];
}

- (IBAction)closeAction:(id)sender {
    [[BLEManager sharedManager] closeDeviceAction];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)goBackAction:(id)sender {
    [[BLEManager sharedManager] reSeachAction];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)setTimeAction:(UIButton *)sender {
  //  if (![_connectStatusLabel.text isEqualToString:@"已连接"]){
        [[BLEManager sharedManager] setTime];
   // }
}

- (void)RefreshDetailDataAction:(NSNotification *)notification {
    
    BLEDataModel *dataModel = notification.object;
    NSLog(@"%@,",dataModel.batteryValue);
    if (dataModel.bleObject) {
//        _connectStatusLabel.text = @"已连接";
        _connectStatusLabel.text = dataModel.serialString;
        _connectStatusLabel.backgroundColor = [UIColor greenColor];
    }else{
        _connectStatusLabel.text = @"BLE蓝牙状态：未连接";
        _connectStatusLabel.backgroundColor = [UIColor redColor];
    }
    
    _deviceVersionLabel.text = dataModel.versionString;
    _deviceNameLabel.text = ((CBPeripheral *)dataModel.bleObject).name;
    if (dataModel.isCharge) {
        _chargeStatus.text = [NSString stringWithFormat:@"正在充电,电压:%@",dataModel.batteryValue];
        _chargeStatus.backgroundColor = [UIColor greenColor];
    }else{
        _chargeStatus.text = [NSString stringWithFormat:@"没充电，电压:%@",dataModel.batteryValue];
    }
    
    _chargePercent.text = [NSString stringWithFormat:@"%@%%",dataModel.batteryPercent];
    
    if(dataModel.Gsensor && dataModel.interrupt){
        _stepStatus.text = @"Gsensr和中断均正常";
        _stepStatus.backgroundColor = [UIColor greenColor];
    }else if (dataModel.Gsensor){
        _stepStatus.text = @"中断不正常";
        _stepStatus.backgroundColor = [UIColor redColor];
    }else if(dataModel.interrupt){
        _stepStatus.text = @"Gsensor不正常";
        _stepStatus.backgroundColor = [UIColor redColor];
    }else{
        _stepStatus.text = @"Gsensr和中断均不正常";
        _stepStatus.backgroundColor = [UIColor redColor];
    }
    
    _hardVersion.text = dataModel.hardwareVersionString;
    _stepNumber.text = [NSString stringWithFormat:@"步数:%d",dataModel.stepNumber];
}

- (void)initViewToResearch{
    _connectStatusLabel.backgroundColor = [UIColor grayColor];
    _stepStatus.backgroundColor = [UIColor grayColor];
}

@end
