//
//  UIView+Gradien.m
//  ShanGuo
//
//  Created by 陈浩 on 2019/1/13.
//  Copyright © 2019 apple. All rights reserved.
//

#import "UIView+Gradien.h"

@implementation UIView (Gradien)
- (UIView *)gradientViewWithCornerRadius:(CGFloat)cornerRadius  lineWidth:(CGFloat)lineWidth size:(CGSize)btnSize colorArray:(NSArray *)clrs gradientType:(GradientType)typ{
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(.0, .0, btnSize.width , btnSize.height);
    
    // 设置渐变颜色数组
    //    gradientLayer.colors = @[(id)RGB(84, 192, 250).CGColor,(id)RGB(67, 136, 247).CGColor];
    gradientLayer.colors = clrs;
    //    gradientLayer.locations = @[@(.0), @(.5)];//注释会默认平均分布
    
    //    （0，0）为左上角、（1，0）为右上角、（0，1）为左下角、（1，1）为右下角，默认是值是（0.5，0）和（0.5，1）
    
    CGPoint start;
    CGPoint end;
    switch (typ) {
        case GradientFromTopToBottom:
            start = CGPointMake(.0, .0);
            end = CGPointMake(.0, 1.0);
            break;
        case GradientFromLeftToRight:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(1.0, 0.0);
            break;
        case GradientFromLeftTopToRightBottom:
            start =  CGPointMake(0.0, 0.0);
            end = CGPointMake(1.0, 1.0);
            break;
        case GradientFromLeftBottomToRightTop:
            start = CGPointMake(.0, 1.0);
            end = CGPointMake(1.0, 0.0);
            break;
        default:
            break;
    }
    
    // 设置渐变起始点
    gradientLayer.startPoint =start ;// CGPointMake(.0, .0);
    // 设置渐变结束点
    gradientLayer.endPoint = end;//CGPointMake(1.0, .0);
    //
    if (cornerRadius) {
        gradientLayer.cornerRadius = cornerRadius;
    }
    
    [self.layer addSublayer:gradientLayer];
    
    
    if (lineWidth) {
        //环
        //        CGFloat lineWidth = 5.0;//边框宽度
        CGFloat rectSideWidth = btnSize.width - lineWidth;
        CGFloat rectSideHeight = btnSize.height - lineWidth;
        
        //    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:(CGRect){lineWidth / 2, lineWidth / 2, rectSideWidth, rectSideHeight}];
        //    path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(arcView.bounds.size.width / 2, arcView.bounds.size.height / 2) radius:rectSide / 2 startAngle:-7.0 / 6 * M_PI endAngle:-11.0 / 6 * M_PI clockwise:YES];
        
        //选择部分圆角 UIRectEdgeLeft UIRectCornerBottomLeft
        //    path = [UIBezierPath bezierPathWithRoundedRect:(CGRect){lineWidth / 2, lineWidth / 2, rectSide, rectSide} byRoundingCorners:UIRectEdgeLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(10, 10)];
        
        //全部圆角 空心
        UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(lineWidth / 2, lineWidth / 2,rectSideWidth, rectSideHeight) cornerRadius:cornerRadius];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        
        shapeLayer.lineWidth = lineWidth;
        //    shapeLayer.lineCap = @"round";
        
        gradientLayer.mask = shapeLayer;
        
//        self.layer.mask = shapeLayer;

        
    }
    
    
    return self;
}
@end
