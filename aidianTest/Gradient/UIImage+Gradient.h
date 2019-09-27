//
//  UIImage+Gradient.h
//  testLayer
//
//  Created by tb on 17/3/17.
//  Copyright © 2017年 com.tb. All rights reserved.
//

#import <UIKit/UIKit.h>
#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
typedef NS_ENUM(NSInteger, GradientType) {
    GradientFromTopToBottom = 1,            //从上到下
    GradientFromLeftToRight,                //从左到右
    GradientFromLeftTopToRightBottom,       //从左上到右下
    GradientFromLeftBottomToRightTop        //从左下到右上
};

@interface UIImage (Gradient)

/**
 *  根据给定的颜色，生成渐变色的图片
 *  @param imageSize        要生成的图片的大小
 *  @param colorArr         渐变颜色的数组
 *  @param percents          渐变颜色的占比数组
 *  @param gradientType     渐变色的类型
 */
- (UIImage *)createImageWithSize:(CGSize)imageSize gradientColors:(NSArray *)colorArr percentage:(NSArray *)percents gradientType:(GradientType)gradientType;

/**
 固定颜色

 @param imageSize 尺寸
 @return 图
 */
+ (UIImage *)createImageWithSize:(CGSize)imageSize  radius:(CGFloat)radius;
/**
 画出圆角

 @param radius 圆角弧度
 @return 图
 */
-(UIImage*)imageWithCornerRadius:(CGFloat)radius;

/**
 生成纯色图片

 @param color <#color description#>
 @param size <#size description#>
 @return <#return value description#>
 */
+ (UIImage *)imageWithSolidColor:(UIColor *)color size:(CGSize)size;

@end
