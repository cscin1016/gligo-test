//
//  DeviceCell.h
//  massor
//
//  Created by 陈双超 on 2018/9/10.
//  Copyright © 2018年 陈双超. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deviceName;
@property (weak, nonatomic) IBOutlet UILabel *rssiValue;


@end
