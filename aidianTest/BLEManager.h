//
//  BLEManager.h
//  yangBulb
//
//  Created by 陈双超 on 2017/8/24.
//  Copyright © 2017年 陈双超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreBluetooth/CoreBluetooth.h"

@interface BLEManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *cbCentralMgr;
@property (strong, nonatomic) NSMutableDictionary *myTempDataDic;

@property (strong, nonatomic) NSMutableArray *supportDeviceList;

+ (BLEManager *)sharedManager;

- (void)reSeachAction;

- (void)searchAction;

- (void)connectBLEDevice:(CBPeripheral *)peripheral;

- (void)stopScanAction;

- (void)closeDeviceAction;

- (void)sendChekCommand;

- (void)setTime;


@end
