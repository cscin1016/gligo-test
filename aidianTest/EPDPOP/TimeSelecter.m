//
//  TimeSelecter.m
//  aidianTest
//
//  Created by 陈双超 on 2020/2/17.
//  Copyright © 2020 陈双超. All rights reserved.
//

#import "TimeSelecter.h"

@implementation TimeSelecter 

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor lightGrayColor];
    
    _datePick = [[UIDatePicker alloc] init];
    _datePick.datePickerMode = UIDatePickerModeTime;
    [_datePick setDate:[NSDate date] animated:YES];
    //监听DataPicker的滚动
    [_datePick addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_datePick];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dateChange:(UIDatePicker *)datePicker {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    //设置时间格式
    formatter.dateFormat = @"yyyy年 MM月 dd日";
    NSString *dateStr = [formatter  stringFromDate:datePicker.date];
    
    
}

@end
