//
//  UIButton+Gradient.h
//  testLayer
//
//  Created by tb on 17/3/17.
//  Copyright © 2017年 com.tb. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIImage+Gradient.h"


@interface UIButton (Gradient)

/**
 *  根据给定的颜色，设置按钮的颜色
 *  @param btnSize  这里要求手动设置下生成图片的大小，防止coder使用第三方layout,没有设置大小
 *  @param clrs     渐变颜色的数组
 *  @param percent  渐变颜色的占比数组
 *  @param type     渐变色的类型
 */
- (UIButton *)gradientButtonWithSize:(CGSize)btnSize colorArray:(NSArray *)clrs percentageArray:(NSArray *)percent gradientType:(GradientType)type;


/**
 渐变蓝色-圆角

 @param state button 状态
 @return button对象
 */
- (UIButton *)gradientBlueButtonForState:(UIControlState)state;


#pragma mark - 渐变图绘制方法2
/**
 渐变图

 @param cornerRadius 圆角 nil则为无圆角
 @param lineWidth 边框宽度 设置则有边框 nil则无边框
 @param btnSize 尺寸
 @param clrs 颜色数组
 @param typ 类型 (从左到右 。。。)
 @return button
 */
- (UIButton *)gradientButtonWithCornerRadius:(CGFloat)cornerRadius  lineWidth:(CGFloat)lineWidth size:(CGSize)btnSize colorArray:(NSArray *)clrs gradientType:(GradientType)typ;


/**
 封装画渐变边的

 @param lineWidth  = 0 则为实心的
 */
- (UIButton *)gradientButtonWithLineWidth:(CGFloat)lineWidth;

@end
