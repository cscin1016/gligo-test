//
//  BLEManager.m
//  yangBulb
//
//  Created by 陈双超 on 2017/8/24.
//  Copyright © 2017年 陈双超. All rights reserved.
//

#import "BLEManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import "BLEDataModel.h"

/*系统定时器产生的随机数*/
#define random_number() arc4random()

#pragma pack(1)
typedef struct
{
    UInt16 randonNumber;//0xFFFF
    UInt32 resultNumber;
}commandObject;
#pragma pack()


#define TRANSFER_CHARACTERISTIC_UUID_FF21    @"FF21"
#define TRANSFER_CHARACTERISTIC_UUID_FF22    @"FF22"

typedef NS_ENUM(NSInteger, VersionMode) {
    
    NOPASSWORDDEVICE = 0,
    /** 没有加密码的设备 */
    BOTHCHECKPASSWORD
    /** 两边都做校验的设备 */
    
};

static BLEManager *manager = nil;

@implementation BLEManager {
    VersionMode versionModeStatus;
    int numberOfStep;//收到3次20字节的数据时才返回
    int stepSum;
}

+ (BLEManager *)sharedManager {
    static dispatch_once_t once;//单例线程安全，只会执行一次
    dispatch_once(&once, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendDataAction:) name:@"BLEDataNotification" object:nil];
        self.cbCentralMgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _myTempDataDic = [NSMutableDictionary new];
    }
    return self;
}

- (void)sendDataAction:(NSNotification *)notification {
    
    for(int i = 0; i < _myTempDataDic.allValues.count; i++){
        CBPeripheral *tempPeripheral = (CBPeripheral *)(((BLEDataModel*)_myTempDataDic.allValues[i]).bleObject);
        if (tempPeripheral.state == 2){
//            NSLog(@"发送的数据：%@",[[notification userInfo] objectForKey:@"tempData"]);
            [self sendDatawithperipheral:tempPeripheral characteristic:TRANSFER_CHARACTERISTIC_UUID_FF21 data:[[notification userInfo] objectForKey:@"tempData"] ];
        }else{
//            NSLog(@"未连接");
        }
    }
    
}

//根据蓝牙对象和特性发送数据
-(void)sendDatawithperipheral:(CBPeripheral *)peripheral characteristic:(NSString*)characteristicStr data:(NSData*)data {
//    NSLog(@"发送data:%@",data);
    for(int i=0; i<peripheral.services.count; i++){
        for (CBCharacteristic *characteristic in [[peripheral.services objectAtIndex:i] characteristics]){
//            NSLog(@"%@",characteristic);
            //找到通信的的特性
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:characteristicStr]]){
                NSLog(@"=============写数据成功");
                [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            }
        }
    }
}

- (void)searchAction {
    NSLog(@"扫描");
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    [self.cbCentralMgr scanForPeripheralsWithServices:nil options:dic];
}

- (void)stopScanAction {
    [self.cbCentralMgr stopScan];
}

- (void)reSeachAction{
    NSLog(@"搜索");
    //    NSArray *arr = [self.cbCentralMgr retrieveConnectedPeripheralsWithServices:[NSArray new]];
    //    NSLog(@"====:%@",arr);
    if (self.cbCentralMgr.isScanning) {
        [self.cbCentralMgr stopScan];
    }
    
    //将当前所有连接的蓝牙断开重新搜索
    for (int i = 0; i < [_myTempDataDic.allValues count]; i++) {
        CBPeripheral * peripheral = ((BLEDataModel*)[_myTempDataDic.allValues objectAtIndex:i]).bleObject;
        if (peripheral.state != 0) {
            NSLog(@"取消连接:%@",peripheral.name);
            [self.cbCentralMgr cancelPeripheralConnection:peripheral];
        }
    }
    [_myTempDataDic removeAllObjects];

    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    if (self.cbCentralMgr) {
        [self.cbCentralMgr scanForPeripheralsWithServices:nil options:dic];
    }
}

- (void)connectBLEDevice:(CBPeripheral *)peripheral {
    [self.cbCentralMgr connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
}

#pragma mark - Navigation

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            break;
        case CBCentralManagerStatePoweredOn:
            [self searchAction];
            break;
        default:
            break;
    }
}

//1.发现设备，判断是否为优莱科产品   2.判断是否已存在相同UUID    3.判断属于哪一种类型  4.是否是已连接过的产品
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //未发生两个商标事故之前，kCBAdvDataServiceUUIDs：AD120387
    //2018年8月1日修改    11320065:11是厂家，32是硬件版本号，0065是软件版本号
    //厂家11是指出给佛山吴总
    //0065=101，是给nikki的软件版本号
    
    NSInteger mySegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"SegmentIndex"];
//    NSString *ADUUIDSTr = [[[advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"] objectAtIndex:0] UUIDString];
    if (!(([peripheral.name isEqualToString:@"GliGO Watch One Plus"]&&mySegmentIndex==1)
          ||([peripheral.name isEqualToString:@"GLAGOM ONE"]&&mySegmentIndex == 0))) {
//        NSLog(@"收到不属于本公司的蓝牙4.0设备：%@",peripheral.name);
        return;
    }
    NSInteger rssiFlag = [[NSUserDefaults standardUserDefaults] integerForKey:@"RSSIStr"];
    if (rssiFlag > RSSI.integerValue || RSSI.integerValue==127) {
        if ([_myTempDataDic objectForKey:[peripheral.identifier UUIDString]]) {
            [_myTempDataDic removeObjectForKey:[peripheral.identifier UUIDString]];
        }
    }else{
        BLEDataModel *dataModel;
        if([_myTempDataDic.allKeys containsObject:[peripheral.identifier UUIDString]]){
            dataModel = [_myTempDataDic objectForKey:[peripheral.identifier UUIDString]];
        }else {
            dataModel = [[BLEDataModel alloc] init];
        }
        dataModel.bleObject = peripheral;
        dataModel.Rssi = [RSSI intValue];
        [_myTempDataDic setObject:dataModel forKey:[peripheral.identifier UUIDString]];
    }
//    NSLog(@"-----%@",[peripheral.identifier UUIDString]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshBLEData" object:_myTempDataDic];
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"连接成功");
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshBLEData" object:_myTempDataDic];
    
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"连接断开");
    
    [self reSeachAction];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshBLEData" object:_myTempDataDic];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"%@,接收到数据：%@",[characteristic.UUID UUIDString],characteristic.value);
//    NSString *str = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    NSString *str = [NSString stringWithUTF8String:[characteristic.value bytes]];
    NSLog(@"======%@",str);
    BOOL isOver = NO;
    BLEDataModel *dataModel;
    if([_myTempDataDic.allKeys containsObject:[peripheral.identifier UUIDString]]){
        dataModel = [_myTempDataDic objectForKey:[peripheral.identifier UUIDString]];
    }else {
        NSLog(@"出现异常，发现不存在的设备");
        return;
    }
    
    if ([[characteristic.UUID UUIDString] isEqualToString:@"2A26"]) {
        dataModel.versionString = [NSMutableString stringWithString:str];
    }else if ([[characteristic.UUID UUIDString] isEqualToString:@"2A27"]) {
        dataModel.hardwareVersionString = [NSMutableString stringWithString:str];
    }else if ([[characteristic.UUID UUIDString] isEqualToString:@"2A25"]) {
        dataModel.serialString = [NSMutableString stringWithString:str];
    }else if ([[characteristic.UUID UUIDString] isEqualToString:@"FF22"]){
        
        NSString *tempStr = [[NSString stringWithFormat:@"%@",characteristic.value] stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (characteristic.value.length == 4) {
            if ([[tempStr substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"1"]) {
                dataModel.Gsensor = YES;
            }else{
                dataModel.Gsensor = NO;
            }
            if ([[tempStr substringWithRange:NSMakeRange(4, 1)] isEqualToString:@"1"]) {
                dataModel.interrupt = YES;
            }else{
                dataModel.interrupt = NO;
            }
            NSString * temp10 = [NSString stringWithFormat:@"%.3f",strtoul([[tempStr substringWithRange:NSMakeRange(5, 4)] UTF8String],0,16)/1000.0];
            dataModel.batteryValue = temp10;
           
        }else if (characteristic.value.length == 3){
            if ([[tempStr substringWithRange:NSMakeRange(5, 2)] isEqualToString:@"00"]) {
                dataModel.isCharge = NO;
            }else{
                dataModel.isCharge = YES;
            }
            NSString * temp10 = [NSString stringWithFormat:@"%lu",strtoul([[tempStr substringWithRange:NSMakeRange(3, 2)] UTF8String],0,16)];
            dataModel.batteryPercent = temp10;
        }else if (characteristic.value.length == 20){
            numberOfStep++;
            
            for(int m=4; m<20; m++){
                
               int tempNum = strtoul([[tempStr substringWithRange:NSMakeRange(m*2+1, 2)] UTF8String],0,16);
                if (m%2==0) {
                    stepSum += tempNum;
                }else{
                    stepSum += tempNum*256;
                }
            }
            if (numberOfStep == 3) {
                isOver = YES;
                dataModel.stepNumber = stepSum;
                numberOfStep = 0;
                stepSum = 0;
            }
        }
    }
    [_myTempDataDic setObject:dataModel forKey:[peripheral.identifier UUIDString]];
    if (isOver) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshBLEDetailData" object:dataModel];
    }
    
}

//返回的蓝牙特征值通知代理
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic * characteristic in service.characteristics) {
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        NSLog(@"=========:%@,%@",[service.UUID UUIDString],[characteristic.UUID UUIDString]);
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID_FF22]])
        {
           [self sendChekCommand:peripheral];
        }
        
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A26"]]||
           [characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A27"]]||
           [characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A25"]]){
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
    
}

//返回的蓝牙服务通知通过代理
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    //    [self addLog:@"发现蓝牙服务，启动特性搜索"];
    for (CBService* service in peripheral.services)
    {
        //查询服务所带的特征值
        [peripheral discoverCharacteristics:nil forService:service];
        //获取设备信息，保留，以后可能用到
        [peripheral discoverIncludedServices:nil forService:service];
    }
}


- (void)sendChekCommand:(CBPeripheral *)peripheral{
    numberOfStep = 0;
    stepSum = 0;
    NSLog(@"发送查询指令");
    char strcommand[1] = {0x91};
    NSData *cmdData = [NSData dataWithBytes:strcommand length:1];
   // NSLog(@"%@", cmdData);
    [self sendDatawithperipheral:peripheral characteristic:TRANSFER_CHARACTERISTIC_UUID_FF21 data:cmdData];
    
    strcommand[0] = 0x0B;
    cmdData = [NSData dataWithBytes:strcommand length:1];
   // NSLog(@"%@", cmdData);
    [self sendDatawithperipheral:peripheral characteristic:TRANSFER_CHARACTERISTIC_UUID_FF21 data:cmdData];
    
    char command[2] = {0x09,0x01};
    cmdData = [NSData dataWithBytes:command length:2];
  //  NSLog(@"%@", cmdData);
    [self sendDatawithperipheral:peripheral characteristic:TRANSFER_CHARACTERISTIC_UUID_FF21 data:cmdData];
    
}

- (void)closeDeviceAction{
    for(int i = 0; i < _myTempDataDic.allValues.count; i++){
        CBPeripheral *tempPeripheral = (CBPeripheral *)(((BLEDataModel*)_myTempDataDic.allValues[i]).bleObject);
        if (tempPeripheral.state == 2){
            char strcommand[4] = {0x92,0x10,0x02,0x32};
            NSData *cmdData = [NSData dataWithBytes:strcommand length:4];
            [self sendDatawithperipheral:tempPeripheral characteristic:TRANSFER_CHARACTERISTIC_UUID_FF21 data:cmdData ];
        }else{
            //            NSLog(@"未连接");
        }
    }
}

- (void)sendChekCommand{
    for(int i = 0; i < _myTempDataDic.allValues.count; i++){
        CBPeripheral *tempPeripheral = (CBPeripheral *)(((BLEDataModel*)_myTempDataDic.allValues[i]).bleObject);
        if (tempPeripheral.state == 2){
            [self sendChekCommand:tempPeripheral];
            return;
        }
    }
}

- (void)setTime{
    for(int i = 0; i < _myTempDataDic.allValues.count; i++){
        CBPeripheral *tempPeripheral = (CBPeripheral *)(((BLEDataModel*)_myTempDataDic.allValues[i]).bleObject);
        if (tempPeripheral.state == 2){
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
            NSString *dateStr = [df stringFromDate:[NSDate date]];
            NSArray *dateArr = [dateStr componentsSeparatedByString:@"-"];
            
            Byte value[7]={0};
            value[0]=0x02;
            value[1]=[dateArr[0] integerValue]-2000;
            value[2]=[dateArr[1] integerValue];
            value[3]=[dateArr[2] integerValue];
            value[4]=[dateArr[3] integerValue];
            value[5]=[dateArr[4] integerValue];
            value[6]=[dateArr[5] integerValue];
            
            NSData* sendData = [[NSData alloc] initWithBytes:value length:sizeof(value)];//sizeof()功能：计算数据空间的字节数
            
            [self sendDatawithperipheral:tempPeripheral characteristic:TRANSFER_CHARACTERISTIC_UUID_FF21 data:sendData ];
        }else{
            //            NSLog(@"未连接");
        }
    }
}

@end
