//
//  BLEDataModel.h
//  aidianTest
//
//  Created by 陈双超 on 2019/5/8.
//  Copyright © 2019 陈双超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreBluetooth/CoreBluetooth.h"

NS_ASSUME_NONNULL_BEGIN

@interface BLEDataModel : NSObject

@property (strong, nonatomic) CBPeripheral *bleObject;//蓝牙对象
@property (assign, nonatomic) int Rssi;//信号强度
@property (strong, nonatomic) NSMutableString *versionString;//版本号
@property (strong, nonatomic) NSMutableString *hardwareVersionString;//生产序列号
@property (assign, nonatomic) int stepNumber;//步数
@property (strong, nonatomic) NSString* batteryValue;//电压
@property (strong, nonatomic) NSString* batteryPercent;//电量百分比
@property (assign, nonatomic) BOOL Gsensor;//1表示正常
@property (assign, nonatomic) BOOL interrupt;//1表示正常
@property (assign, nonatomic) BOOL isCharge;//1表示在充电

@property (nonatomic, strong) NSString *serialString;//序列号

@end

NS_ASSUME_NONNULL_END
