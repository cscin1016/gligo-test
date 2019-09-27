//
//  UIImage+Gradient.m
//  testLayer
//
//  Created by tb on 17/3/17.
//  Copyright © 2017年 com.tb. All rights reserved.
//

#import "UIImage+Gradient.h"

@implementation UIImage (Gradient)

- (UIImage *)createImageWithSize:(CGSize)imageSize gradientColors:(NSArray *)colors percentage:(NSArray *)percents gradientType:(GradientType)gradientType {
    
    NSAssert(percents.count <= 5, @"输入颜色数量过多，如果需求数量过大，请修改locations[]数组的个数");
    
    NSMutableArray *ar = [NSMutableArray array];
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    
//    NSUInteger capacity = percents.count;
//    CGFloat locations[capacity];
    CGFloat locations[5];
    for (int i = 0; i < percents.count; i++) {
        locations[i] = [percents[i] floatValue];
    }
    
     //1.开启上下文
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 1);
    //获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, locations);
    CGPoint start;
    CGPoint end;
    switch (gradientType) {
        case GradientFromTopToBottom:
            start = CGPointMake(imageSize.width/2, 0.0);
            end = CGPointMake(imageSize.width/2, imageSize.height);
            break;
        case GradientFromLeftToRight:
            start = CGPointMake(0.0, imageSize.height/2);
            end = CGPointMake(imageSize.width, imageSize.height/2);
            break;
        case GradientFromLeftTopToRightBottom:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(imageSize.width, imageSize.height);
            break;
        case GradientFromLeftBottomToRightTop:
            start = CGPointMake(0.0, imageSize.height);
            end = CGPointMake(imageSize.width, 0.0);
            break;
        default:
            break;
    }
    
    
//    CGFloat lineWidth = 10;
//    // 裁剪区域
//    CGFloat rectSideWidth = imageSize.width - lineWidth;
//    CGFloat rectSideHeight = imageSize.height - lineWidth;
//
//    UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);

//    //全部圆角 空心
//    UIBezierPath * clipPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0,imageSize.width, imageSize.height) cornerRadius:10];
//////    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
////    [clipPath addClip];
////    [self drawInRect:CGRectMake(0, 0,imageSize.width, imageSize.height)];
////    CGContextClipToRects(context, clipPath.closePath, 5);
//
//    [clipPath closePath];
//    [clipPath addClip];
    
//CGContextSetRGBFillColor(context, 0, 1.0, 0, 1);//设置填充色
    
//    CGContextClipToRect(context, clipPath.bounds);

//    UIRectClip(CGRectMake(20, 50, rectSideWidth, rectSideHeight));
    
//    CGContextSetLineWidth(context, 10);

    
//    CGContextSetLineWidth(context, 3.0);
//    
//    // 设置线的颜色
//    
//    CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
//    //全部圆角 空心
//    UIBezierPath * clipPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0,imageSize.width, imageSize.height) cornerRadius:10];
//
//    CGContextAddPath(context, clipPath.CGPath);
//    CGContextStrokePath(context);
    
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}
-(UIImage*)imageWithCornerRadius:(CGFloat)radius{
    
    CGRect rect = (CGRect){0.f,0.f,self.size};
    
    // void UIGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale);
    //size——同UIGraphicsBeginImageContext,参数size为新创建的位图上下文的大小
    //    opaque—透明开关，如果图形完全不用透明，设置为YES以优化位图的存储。
    //    scale—–缩放因子
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
    
    
    //根据矩形画带圆角的曲线
//    CGContextAddPath(UIGraphicsGetCurrentContext(), [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius].CGPath);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
    
    [self drawInRect:rect];
    
    //图片缩放，是非线程安全的
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    
    //关闭上下文
    UIGraphicsEndImageContext();
    
    return image;
   
}
+ (UIImage *)imageWithSize:(CGSize)size drawer:(void(^)(CGContextRef context, CGRect bounds))drawer {
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    drawer(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
+ (UIImage *)createImageWithSize:(CGSize)imageSize radius:(CGFloat)radius{
    UIImage * image = [[UIImage alloc]createImageWithSize:imageSize gradientColors:@[(id)RGB(84, 192, 250),(id)RGB(67, 136, 247)] percentage:@[@(0),@(1)] gradientType:GradientFromLeftToRight];
    image = [image imageWithCornerRadius:radius];
    return image;
}

+ (UIImage *)imageWithSolidColor:(UIColor *)color size:(CGSize)size {
    return [self imageWithSize:size drawer:^(CGContextRef context, CGRect bounds) {
        [color setFill];
        CGContextFillRect(context, bounds);
    }];
}
@end
