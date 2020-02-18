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
#import "HHAlertView.h"
#import <AFNetworking/AFNetworking.h>
#import "NetWork.h"
#import "PopupView.h"

#define queueMainStart dispatch_async(dispatch_get_main_queue(), ^{
#define queueEnd  });


@interface BLEDetailVC (){
    NSString *UUIDStr;
    NSString *devTypeStr;
    NSString *versionString;
    NSString *hardwareVersionString;
    NSString *batteryPercent;
    
    NSInteger screenOK;
    NSInteger shockOK;
    NSInteger PointerOK;
    BOOL gsensorOK;
    NSInteger heartRateOK;
    NSInteger stepOK;
}

@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *SNLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceVersionLabel;


@property (weak, nonatomic) IBOutlet UILabel *connectStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *chargeStatus;
@property (weak, nonatomic) IBOutlet UILabel *stepStatus;
@property (weak, nonatomic) IBOutlet UILabel *stepNumber;

@property (weak, nonatomic) IBOutlet UILabel *screenLabel;
@property (weak, nonatomic) IBOutlet UILabel *shockLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointerLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeDifferenceLabel;


@end

@implementation BLEDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RefreshDetailDataAction:) name:@"RefreshBLEDetailData" object:nil];
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkStepAction)];
//    [_stepNumber addGestureRecognizer:tapGesture];
}

//重新测试
- (IBAction)reCheckAction:(UIButton *)sender {
    [self initViewToResearch];
    [[BLEManager sharedManager] sendChekCommand];
}

//关机
- (IBAction)closeAction:(id)sender {
    [[BLEManager sharedManager] closeDeviceAction];
    [self.navigationController popViewControllerAnimated:YES];
}

//返回
- (IBAction)goBackAction:(id)sender {
    [[BLEManager sharedManager] reSeachAction];
    [self.navigationController popViewControllerAnimated:YES];
}

//同步时间
- (IBAction)setTimeAction:(UIButton *)sender {
    [[BLEManager sharedManager] setTime];
}

//收到测试数据处理
- (void)RefreshDetailDataAction:(NSNotification *)notification {
    
    BLEDataModel *dataModel = notification.object;
    _deviceNameLabel.text = ((CBPeripheral *)dataModel.bleObject).name;
    _deviceNameLabel.backgroundColor = [UIColor greenColor];
    _SNLabel.text = [NSString stringWithFormat:@"SN:%@",dataModel.serialString] ;
    _SNLabel.backgroundColor = [UIColor greenColor];
    _deviceVersionLabel.text = [NSString stringWithFormat:@"固件版本:%@   ，HRS:%@",dataModel.versionString,dataModel.hardwareVersionString];
    _deviceVersionLabel.backgroundColor = [UIColor greenColor];
    
    versionString = dataModel.versionString;
    hardwareVersionString = dataModel.hardwareVersionString;
    
    if(dataModel.bleObject) {
        _connectStatusLabel.text = @"已连接";
        _connectStatusLabel.backgroundColor = [UIColor greenColor];
        UUIDStr = [dataModel.bleObject.identifier UUIDString];
    }else{
        _connectStatusLabel.text = @"BLE蓝牙状态：未连接";
        _connectStatusLabel.backgroundColor = [UIColor redColor];
        return;
    }
    
    
    if (dataModel.isCharge) {
        _chargeStatus.text = [NSString stringWithFormat:@"正在充电，电压:%@，电量:%@%%",dataModel.batteryValue,dataModel.batteryPercent];
        _chargeStatus.backgroundColor = [UIColor greenColor];
    }else{
        _chargeStatus.text = [NSString stringWithFormat:@"没充电，电压:%@，电量:%@%%",dataModel.batteryValue,dataModel.batteryPercent];
    }
    
    batteryPercent = dataModel.batteryPercent;
    gsensorOK = dataModel.Gsensor;
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
    
    _stepNumber.text = [NSString stringWithFormat:@"步数:%d",dataModel.stepNumber];
    
    
    NSDictionary *parameters = @{@"uuid": UUIDStr,
                                 @"devType":_deviceNameLabel.text,
                                 @"fwVersion":versionString,
                                 @"productId":hardwareVersionString,
                                 @"weight":@"",
                                 @"size":@"",
                                 @"tester":  [[NSUserDefaults standardUserDefaults] objectForKey:@"QCNameKey"]};
    NSLog(@"保存设备基本信息存在逻辑BUG，测试人员，版本号会变动，需要多次保存这个信息");
    [[NetWork sharedInstance] postDataWithUrl:@"dmf/bleinfo/save" parameters:parameters success:^(NSURLSessionDataTask * task , id responseObject) {
        NSLog(@"请求成功：%@",(NSURLSessionDataTask*)task);
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSDictionary *allHeaders = response.allHeaderFields;
        if ([allHeaders[@"retCode"] intValue] ) {
            NSLog(@"该设备的值已经存在");
        }else{
            NSLog(@"添加成功");
        }
    } failure:^(NSError *error) {
        NSLog(@"请求失败");
    }];
    
    [self checkScreenAction];
}


//重新测试前，状态初始化
- (void)initViewToResearch{
    _connectStatusLabel.backgroundColor = [UIColor grayColor];
    _stepStatus.backgroundColor = [UIColor grayColor];
}

- (void)checkScreenAction{
    HHAlertView *alertview = [[HHAlertView alloc] initWithTitle:@"屏幕显示" detailText:NSLocalizedString(@"1.请仔细查看手表的所有段数是否显示完整\n2.闪动的时候不能有异常残影", nil) cancelButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"下一步", nil)]];
    alertview.mode = HHModeRadioSelect;
    [alertview showWithBlock:^(NSInteger index, NSInteger radioIndex) {
        self->screenOK = radioIndex;
        queueMainStart
        if (radioIndex == 0) {
            self.screenLabel.backgroundColor = [UIColor greenColor];
            self.screenLabel.text = @"屏幕显示：正常";
        }else {
            self.screenLabel.backgroundColor = [UIColor redColor];
            self.screenLabel.text = @"屏幕显示：不正常";
        }
        [self checkShockAction];
        queueEnd
    }];
}

- (void)checkShockAction{
    HHAlertView *alertview = [[HHAlertView alloc] initWithTitle:@"震动测试" detailText:NSLocalizedString(@"1.请操作手表按键感觉是否有震动反馈", nil) cancelButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"下一步", nil)]];
    alertview.mode = HHModeRadioSelect;
    [alertview showWithBlock:^(NSInteger index, NSInteger radioIndex) {
        self->shockOK = radioIndex;
        queueMainStart
        if (radioIndex == 0) {
            self.shockLabel.backgroundColor = [UIColor greenColor];
            self.shockLabel.text = @"马达震动：正常";
        }else {
            self.shockLabel.backgroundColor = [UIColor redColor];
            self.shockLabel.text = @"马达震动：不正常";
        }
        [self checkPointAction];
        queueEnd
    }];
}

- (void)checkPointAction{
     HHAlertView *alertview = [[HHAlertView alloc] initWithTitle:@"石英机芯走时" detailText:NSLocalizedString(@"1.请查看指针走时是否正常", nil) cancelButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"下一步", nil)]];
     alertview.mode = HHModeRadioSelect;
     [alertview showWithBlock:^(NSInteger index, NSInteger radioIndex) {
         self->PointerOK = radioIndex;
         queueMainStart
         if (radioIndex == 0) {
             self.pointerLabel.backgroundColor = [UIColor greenColor];
             self.pointerLabel.text = @"指针走时：正常";
         }else {
             self.pointerLabel.backgroundColor = [UIColor redColor];
             self.pointerLabel.text = @"指针走时：不正常";
         }
         [self checkHeartRateAction];
         queueEnd
     }];
 }

- (void)checkHeartRateAction{
    HHAlertView *alertview = [[HHAlertView alloc] initWithTitle:@"心率测试" detailText:NSLocalizedString(@"1.请仔细查看手表所有段数是否显示完整\n2.闪动的时候不能有异常残影", nil) cancelButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"下一步", nil)]];
    alertview.mode = HHModeRadioSelect;
    [alertview showWithBlock:^(NSInteger index, NSInteger radioIndex) {
        self->heartRateOK = radioIndex;
        queueMainStart
        if (radioIndex == 0) {
            self.heartRateLabel.backgroundColor = [UIColor greenColor];
            self.heartRateLabel.text = @"心率：正常";
        }else {
            self.heartRateLabel.backgroundColor = [UIColor redColor];
            self.heartRateLabel.text = @"心率：不正常";
        }
        [self checkStepAction];
        queueEnd
    }];
}

- (void)checkStepAction{
    HHAlertView *alertview = [[HHAlertView alloc] initWithTitle:@"计步检测" detailText:NSLocalizedString(@"1.请确认计步功能是否正常", nil) cancelButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"确定", nil)]];
    alertview.mode = HHModeRadioSelect;
    [alertview showWithBlock:^(NSInteger index, NSInteger radioIndex) {
        self->stepOK = radioIndex;
        queueMainStart
        if (radioIndex == 0) {
            self.stepNumber.backgroundColor = [UIColor greenColor];
            self.stepNumber.text = @"计步：正常";
        }else {
            self.stepNumber.backgroundColor = [UIColor redColor];
            self.stepNumber.text = @"计步：不正常";
        }
        [self checkOverAction];
        queueEnd
    }];
}

- (void)checkOverAction{
    NSDateFormatter*dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *URLString = @"http://www.pertietech.com/dmf/test/save";
    NSDictionary *parameters = @{@"uuid": UUIDStr,
                                     @"motor":shockOK==0?@"1":@"0",
                                     @"pointer":PointerOK==0?@"1":@"0",
                                     @"gsensor":gsensorOK?@"1":@"0",
                                     @"heartBeat":heartRateOK==0?@"1":@"0",
                                     @"screen":screenOK==0? @"1":@"0",
                                     @"step":stepOK==0?@"1":@"0",
                                     @"powerOff":currentDateString,
                                     @"testTime":currentDateString,
                                     @"voltage":batteryPercent,
                                     @"tester":[[NSUserDefaults standardUserDefaults] objectForKey:@"QCNameKey"]};
        
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"image/png",@"text/html;charset=UTF-8",@"text/plain", nil];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/x-www-form-urlencoded"];


    [manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"成功:%@",responseObject);
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSDictionary *allHeaders = response.allHeaderFields;
        if ([allHeaders[@"retCode"] intValue] ) {
            NSLog(@"请求的值已经存在");
        }else{
            NSLog(@"添加成功");
            queueMainStart
            PopupView  *popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 240, 0, 0)];
            popUpView.ParentView = self.view;
            [popUpView setText: NSLocalizedString(@"添加测试记录成功",nil)];
            [self.view addSubview:popUpView];
            queueEnd
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"失败:%@",error);
    }];

        
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [segue.destinationViewController setValue:UUIDStr forKey:@"UUIDStr"];
}

@end
