//
//  ViewController.m
//  aidianTest
//
//  Created by 陈双超 on 2019/5/8.
//  Copyright © 2019 陈双超. All rights reserved.
//

#import "ViewController.h"
#import "BLEManager.h"
#import "DeviceCell.h"
#import "PopupView.h"
#import "BLEDataModel.h"

static NSString *CellIdentifier = @"deviceCell";
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource> {
    NSMutableDictionary *bleDic;
}
@property (weak, nonatomic) IBOutlet UITableView *myDeviceTableView;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UISlider *mySlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mySegment;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    bleDic = [NSMutableDictionary new];
    if([BLEManager sharedManager].myTempDataDic.allValues.count != 0){
        bleDic = [NSMutableDictionary dictionaryWithDictionary:[BLEManager sharedManager].myTempDataDic];
        [_myDeviceTableView reloadData];
    }
    
    NSInteger rssiFlag = [[NSUserDefaults standardUserDefaults] integerForKey:@"RSSIStr"];
    if (rssiFlag == 0) {
        rssiFlag = -50;
        [[NSUserDefaults standardUserDefaults] setInteger:rssiFlag forKey:@"RSSIStr"];
    }
    _mySlider.value = rssiFlag;
    _rssiLabel.text = [NSString stringWithFormat:@"信号：%d",(int)rssiFlag];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RefreshDataAction:) name:@"RefreshBLEData" object:nil];
}

- (void)clearTableViewAction{
    bleDic = [NSMutableDictionary new];
    [_myDeviceTableView reloadData];
}

- (IBAction)RefreshAction:(UIButton *)sender {
    [self clearTableViewAction];
    [[BLEManager sharedManager] reSeachAction];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self clearTableViewAction];
}

- (void)RefreshDataAction:(NSNotification *)notification {
//    NSLog(@"----:%@",notification.object);
    bleDic = [NSMutableDictionary dictionaryWithDictionary:notification.object];
    [_myDeviceTableView reloadData];
}

- (IBAction)SliderBarAction:(UISlider *)sender {
    _rssiLabel.text = [NSString stringWithFormat:@"信号：%.0f",sender.value];
    [[NSUserDefaults standardUserDefaults] setInteger:sender.value forKey:@"RSSIStr"];
}

- (IBAction)segmentChangeAction:(UISegmentedControl *)sender {
    [[NSUserDefaults standardUserDefaults] setInteger:sender.selectedSegmentIndex forKey:@"SegmentIndex"];
    [self clearTableViewAction];
    [[BLEManager sharedManager] reSeachAction];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return bleDic.allValues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[DeviceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    BLEDataModel *modelData = (BLEDataModel*)bleDic.allValues[indexPath.row];
    CBPeripheral *ble = (CBPeripheral *)(modelData.bleObject);
    cell.deviceName.text = ble.name;
    cell.rssiValue.text = [NSString stringWithFormat:@"%d",modelData.Rssi];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BLEDataModel *modelData = (BLEDataModel*)bleDic.allValues[indexPath.row];
    CBPeripheral *ble = (CBPeripheral *)(modelData.bleObject);
    if(ble.state == CBPeripheralStateDisconnected) {
        [[BLEManager sharedManager] connectBLEDevice:ble];
        UIViewController *_BLEDetailVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]  instantiateViewControllerWithIdentifier:@"BLEDetailVC"];
        [self.navigationController pushViewController:_BLEDetailVC animated:YES];
        [[BLEManager sharedManager] stopScanAction];
    }else if (ble.state == CBPeripheralStateConnecting){
        PopupView  *popUpView;
        popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 240, 0, 0)];
        popUpView.ParentView = self.view;
        [popUpView setText: NSLocalizedString(@"请靠近设备",@"请靠近设备")];
        [self.view addSubview:popUpView];
    }
}

@end
