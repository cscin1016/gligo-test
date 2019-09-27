//
//  UIView+Gradien.h
//  ShanGuo
//
//  Created by 陈浩 on 2019/1/13.
//  Copyright © 2019 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+Gradient.h"
NS_ASSUME_NONNULL_BEGIN

@interface UIView (Gradien)
- (UIView *)gradientViewWithCornerRadius:(CGFloat)cornerRadius  lineWidth:(CGFloat)lineWidth size:(CGSize)btnSize colorArray:(NSArray *)clrs gradientType:(GradientType)typ;
@end

NS_ASSUME_NONNULL_END
