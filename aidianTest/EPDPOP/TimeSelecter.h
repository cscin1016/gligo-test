//
//  TimeSelecter.h
//  aidianTest
//
//  Created by 陈双超 on 2020/2/17.
//  Copyright © 2020 陈双超. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeSelecter : UIView

@property (nonatomic, strong) UIDatePicker *datePick;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *comformBtn;

@end

NS_ASSUME_NONNULL_END
