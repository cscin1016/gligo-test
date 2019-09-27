//
//  HHAlertViewConst.h
//  HHAlertView
//
//  Created by ChenHao on 6/17/15.
//  Copyright (c) 2015 AEXAIR. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef HHAlertView_HHAlertViewConst_h
#define HHAlertView_HHAlertViewConst_h


#define KHHAlertView_Height    667*0.35
#define KHHAlertView_Height2    [[UIScreen mainScreen] bounds].size.height*0.42
#define KHHAlertView_Height3    [[UIScreen mainScreen] bounds].size.height*0.47


#define KHHAlertView_Width     [[UIScreen mainScreen] bounds].size.width*0.9 //弹框的宽度

#define RadioButtonTag  888

#define AlertViewButtonHeight    40
static const CGFloat KHHAlertView_Padding     = 20;//文字距离b两边的间隙
static const CGFloat KLogoView_Size           = 60;//Logo视图的高度和宽度
static const CGFloat KlogoView_Margin_top    = 20;//Logo距离上面视图的间隙

static const CGFloat KDefaultRadius = 5.0;

static const NSInteger KbuttonTag = 18888;

#define SUCCESS_COLOR [UIColor colorWithRed:126/255.0 green:216/255.0 blue:33/255.0 alpha:1]
#define WARNING_COLOR [UIColor colorWithRed:245/255.0 green:166/255.0 blue:35/255.0 alpha:1]
#define ERROR_COLOR [UIColor colorWithRed:208/255.0 green:2/255.0 blue:27/255.0 alpha:1]

#endif
