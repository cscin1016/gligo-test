//
//  AppDelegate.h
//  aidianTest
//
//  Created by 陈双超 on 2019/5/8.
//  Copyright © 2019 陈双超. All rights reserved.
//

#import "HHAlertView.h"
#import "UIButton+Gradient.h"
#import <sys/utsname.h>

#define OKBUTTON_BACKGROUND_COLOR [UIColor colorWithRed:158/255.0 green:214/255.0 blue:243/255.0 alpha:1]
#define CANCELBUTTON_BACKGROUND_COLOR [UIColor colorWithRed:255/255.0 green:20/255.0 blue:20/255.0 alpha:1]


@interface HHAlertView(){
    NSInteger radioButtonIndex;
}

@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UILabel  *detailLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) NSArray  *otherButtons;

@property (nonatomic, strong) UIView   *logoView;//额外的自定义部分
@property (nonatomic, strong) UIView   *maskView;//黑色阴影蒙层
@property (nonatomic, strong) UIView   *mainAlertView; //main alert view

@end


@implementation HHAlertView

#pragma mark Lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha   = 0.0;
        self.removeFromSuperViewOnHide = YES;
        [self registerKVC];
    }
    return self;
}


- (instancetype)initWithTitle:(NSString *)title
                   detailText:(NSString *)detailtext
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray *)otherButtonsTitles {
    
    
    self = [self initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.titleText = title;
        self.detailText = detailtext;
        self.cancelButtonTitle = cancelButtonTitle;
        self.otherButtonTitles = otherButtonsTitles;
        [self layout];
    }
    return self;
}

#pragma mark UI

- (void)layout {
    [self addView];
    [self setupButton];
    NSArray* windows = [UIApplication sharedApplication].windows;
    UIView *window = [windows objectAtIndex:0];
    [window addSubview:self];
}

- (void)addView {
    [self addSubview:self.maskView];
    [self addSubview:self.mainAlertView];
    
    [self.mainAlertView addSubview:self.logoView];
    
    if (self.titleText.length > 0) {
        [self.mainAlertView addSubview:self.titleLabel];
    }
    
    if (self.detailText.length > 0) {
        [self.mainAlertView addSubview:self.detailLabel];
    }
}

- (void)setupButton {
    if (self.cancelButtonTitle == nil && self.otherButtonTitles ==nil) {
        NSAssert(NO, @"error");
    }
    
    if (self.cancelButtonTitle != nil) {
        self.cancelButton = [[UIButton alloc] init];
        [self.cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
        [self.cancelButton setTag:KbuttonTag];
        [self.cancelButton addTarget:self action:@selector(buttonTouch:) forControlEvents:UIControlEventTouchUpInside];
        [[self.cancelButton layer] setCornerRadius:4.0];
        [self.mainAlertView addSubview:self.cancelButton];
    }
    
    if (self.otherButtonTitles != nil) {
        NSMutableArray *tempButtonArray = [[NSMutableArray alloc] init];
        NSInteger i = 1;
        for (NSString *title in self.otherButtonTitles) {
            
            UIButton *button = [[UIButton alloc] init];
            [button setTitle:title forState:UIControlStateNormal];
            [button setTag:KbuttonTag + i];
            [button addTarget:self action:@selector(buttonTouch:) forControlEvents:UIControlEventTouchUpInside];
            [[button layer] setCornerRadius:4.0];
            
            [tempButtonArray addObject:button];
            [self.mainAlertView addSubview:button];
            i++;
        }
        self.otherButtons = [tempButtonArray copy];
    }
}





#pragma mark Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.mainAlertView setBackgroundColor:[UIColor whiteColor]];
    [[self.mainAlertView layer] setCornerRadius:KDefaultRadius];
    
    CGFloat titleHight,detailHeight,customHeight,buttonHeight;
    titleHight = detailHeight = customHeight = buttonHeight = 0;
    int paddingCount = 1;
    if(self.titleText.length>0){
        titleHight = self.titleLabel.frame.size.height;
        paddingCount++;
    }
    if (self.detailText.length > 0) {
        CGRect tempFrame = self.detailLabel.frame;
        tempFrame.origin.y = paddingCount*KHHAlertView_Padding + titleHight;
        self.detailLabel.frame = tempFrame;
        
        detailHeight = self.detailLabel.frame.size.height;
        paddingCount++;
    }
    if (_logoView) {
        CGRect tempFrame = self.logoView.frame;
        tempFrame.origin.x = (KHHAlertView_Width - self.logoView.frame.size.width)*0.5;
        tempFrame.origin.y = paddingCount*KHHAlertView_Padding + titleHight + detailHeight;
        self.logoView.frame = tempFrame;
        
        customHeight = self.logoView.frame.size.height;
        paddingCount++;
    }
    paddingCount++; 
    
    buttonHeight = 40;
    if (self.otherButtonTitles.count >1) {
        buttonHeight = 40 + self.otherButtonTitles.count*(AlertViewButtonHeight + KHHAlertView_Padding);
    }
    
    CGRect tempFrame = self.mainAlertView.frame;
    tempFrame.size.height = paddingCount*KHHAlertView_Padding + titleHight + detailHeight + customHeight + buttonHeight;
    self.mainAlertView.frame = tempFrame;
    
   
    //只有一个按钮的情况
    if (self.cancelButtonTitle != nil && self.otherButtonTitles == nil){
        CGRect buttonFrame = CGRectMake(KHHAlertView_Padding, self.mainAlertView.frame.size.height - KHHAlertView_Padding - AlertViewButtonHeight, KHHAlertView_Width - KHHAlertView_Padding *2, AlertViewButtonHeight);
        [self.cancelButton setFrame:buttonFrame];
    }
    
    //只有一个按钮的情况
    if (self.cancelButtonTitle == nil && [self.otherButtonTitles count]==1) {
        UIButton *rightButton = (UIButton *)self.otherButtons[0];
        CGRect buttonFrame = CGRectMake(KHHAlertView_Padding, self.mainAlertView.frame.size.height - KHHAlertView_Padding - AlertViewButtonHeight, KHHAlertView_Width - KHHAlertView_Padding *2, AlertViewButtonHeight);
        [rightButton setFrame:buttonFrame];
        
        [rightButton setBackgroundColor:[UIColor blueColor]];
        [rightButton gradientBlueButtonForState:UIControlStateNormal];
    }
    
    if (self.cancelButtonTitle != nil && [self.otherButtonTitles count]==1) {
        
        CGRect buttonFrame = CGRectMake(0, 0, (KHHAlertView_Width - KHHAlertView_Padding *3)/2, AlertViewButtonHeight);
        [self.cancelButton setFrame:buttonFrame];
        [self.cancelButton setBackgroundColor:[UIColor lightGrayColor]];
        
        CAGradientLayer *gradientLayer =  [CAGradientLayer layer];
        gradientLayer.frame = _cancelButton.bounds;
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 0);
        gradientLayer.locations = @[@(0.5),@(1.0)];//渐变点
        [gradientLayer setColors:@[(id)[RGB(225, 225, 225) CGColor],(id)[[UIColor lightGrayColor] CGColor],]];//渐变数组
        [gradientLayer setCornerRadius:4.0];
        [self.cancelButton.layer addSublayer:gradientLayer];
        [[self.cancelButton layer] setCornerRadius:4.0];
        
        
        UIButton *rightButton = (UIButton *)self.otherButtons[0];
        [rightButton setFrame:buttonFrame];
        //add hhy
        [rightButton gradientBlueButtonForState:UIControlStateNormal];
        
        CGPoint rightButtonCenter = CGPointMake(KHHAlertView_Width - CGRectGetWidth(rightButton.frame)/2 - KHHAlertView_Padding, KHHAlertView_Height - KHHAlertView_Padding*2 );
        [rightButton setCenter:rightButtonCenter];
    }
    
    if (self.cancelButtonTitle != nil && [self.otherButtonTitles count]>1) {
        CGRect buttonFrame = CGRectMake(0, 0, KHHAlertView_Width - KHHAlertView_Padding *2, 40);
        
        for (NSInteger i = self.otherButtons.count-1; i>=0; i--) {
            UIButton *button = (UIButton *)self.otherButtons[i];
            [button setFrame:buttonFrame];
            
            CGPoint pointCenter = CGPointMake(CGRectGetWidth(self.mainAlertView.frame)/2, CGRectGetHeight(self.mainAlertView.frame) - KHHAlertView_Padding - 10 *(self.otherButtons.count-i-1)- 40 *(self.otherButtons.count-i)+20);
            [button setCenter:pointCenter];
        }

        [self.cancelButton setFrame:buttonFrame];
        
        CGPoint leftButtonCenter = CGPointMake(CGRectGetWidth(self.mainAlertView.frame)/2, CGRectGetHeight(self.mainAlertView.frame) - KHHAlertView_Padding - 10 *(self.otherButtons.count) - 40 * (self.otherButtons.count)-20);
        [self.cancelButton setCenter:leftButtonCenter];
        
        
        //adjust
        if ((50 * (self.otherButtons.count+1) + CGRectGetMaxY(self.detailLabel.frame))>CGRectGetHeight(self.mainAlertView.frame)) {
            
            CGRect frame = self.mainAlertView.frame;
            frame.size.height = 50 * (self.otherButtons.count+1) + CGRectGetMaxY(self.detailLabel.frame);
            self.mainAlertView.frame = frame;
            [self setNeedsLayout];
            
        }
        
    }
    
    

}

#pragma mark show & hide

- (void)show {
    NSTimeInterval interval = 0.3;
    CGRect frame = self.mainAlertView.frame;
    [self.mainAlertView setFrame:frame];
    [UIView animateWithDuration:interval animations:^{
        [self setAlpha:1];
        [self.mainAlertView setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2)];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)showWithBlock:(selectButtonIndexComplete)completeBlock {
    self.completeBlock = completeBlock;
    [self show];
}

- (void)hide {
    NSTimeInterval interval = 0.3;
    CGRect frame = self.mainAlertView.frame;
    [UIView animateWithDuration:interval animations:^{
        [self setAlpha:0];
        [self.mainAlertView setFrame:frame];
    } completion:^(BOOL finished) {
        if (self.removeFromSuperViewOnHide) {
            [self removeFromSuperview];
        }
        [self unregisterKVC];
    }];
}


#pragma mark Event Response

- (void)buttonTouch:(UIButton *)button {
    if (self.completeBlock) {
        self.completeBlock(button.tag - KbuttonTag, radioButtonIndex);
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(HHAlertView:didClickButtonAnIndex:)]) {
        [self.delegate HHAlertView:self didClickButtonAnIndex:button.tag - KbuttonTag];
    }
    [self hide];
}



#pragma mark KVC

- (void)registerKVC {
    for (NSString *keypath in [self observableKeypaths]) {
        [self addObserver:self forKeyPath:keypath options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)unregisterKVC {
    for (NSString *keypath in [self observableKeypaths]) {
        [self removeObserver:self forKeyPath:keypath];
    }
}

- (NSArray *)observableKeypaths {
    return [NSArray arrayWithObjects:@"mode",@"customView", nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(updateUIForKeypath:) withObject:keyPath waitUntilDone:NO];
    }
    else{
        [self updateUIForKeypath:keyPath];
    }
}

- (void)updateUIForKeypath:(NSString *)keypath {
    if ([keypath isEqualToString:@"mode"] || [keypath isEqualToString:@"customView"]) {
        [self updateModeStyle];
    }
}

- (void)updateModeStyle {
    if (self.mode == HHModeRadioSelect) {
        NSArray *titleArrry = @[NSLocalizedString(@"正常", nil),
                                NSLocalizedString(@"不正常", nil)
                                ];
        
        _logoView.frame = CGRectMake(KHHAlertView_Padding, KHHAlertView_Padding,KHHAlertView_Width-KHHAlertView_Padding*2, titleArrry.count*AlertViewButtonHeight);
        
        for (int i=0; i<titleArrry.count; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, i*AlertViewButtonHeight, _logoView.frame.size.width, AlertViewButtonHeight)];
            [button setImage:[UIImage imageNamed:@"rb_nor"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"rb"] forState:UIControlStateSelected];
            [button setTitle:titleArrry[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.tintColor = [UIColor clearColor];
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            [button addTarget:self action:@selector(radioButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [button setContentHorizontalAlignment: UIControlContentHorizontalAlignmentLeft];
            [button setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
            button.tag = i+RadioButtonTag;
            [_logoView addSubview:button];
        }
        
        if (self.cancelButtonTitle != nil && self.otherButtonTitles == nil){
            self.cancelButton.enabled = NO;
        }
        
        //只有一个按钮的情况
        if (self.cancelButtonTitle == nil && [self.otherButtonTitles count]==1) {
            UIButton *rightButton = (UIButton *)self.otherButtons[0];
            rightButton.enabled = NO;
        }
        
    }
}


- (void)radioButtonAction:(UIButton *)button {
    if (radioButtonIndex != button.tag-RadioButtonTag) {
        UIButton *lastButton = [_logoView viewWithTag:RadioButtonTag+radioButtonIndex];
        lastButton.selected = NO;
    }
    button.selected = YES;
    radioButtonIndex = button.tag-RadioButtonTag;
    if (self.cancelButtonTitle != nil && self.otherButtonTitles == nil){
        self.cancelButton.enabled = YES;
    }
    
    //只有一个按钮的情况
    if (self.cancelButtonTitle == nil && [self.otherButtonTitles count]==1) {
        UIButton *rightButton = (UIButton *)self.otherButtons[0];
        rightButton.enabled = YES;
    }
}

#pragma mark getter and setter

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.bounds];
        [_maskView setBackgroundColor:[UIColor blackColor]];
        [_maskView setAlpha:0.2];
    }
    return _maskView;
}

- (UIView *)mainAlertView {
    if (!_mainAlertView) {
        _mainAlertView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KHHAlertView_Width, KHHAlertView_Height)];
        [_mainAlertView setCenter:self.center];
    }
    return _mainAlertView;
}

- (UIView *)logoView {
    if (!_logoView) {
        _logoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KLogoView_Size, KLogoView_Size)];
    }
    return _logoView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(KHHAlertView_Padding, KHHAlertView_Padding, KHHAlertView_Width-KHHAlertView_Padding*2, 0)];
        _titleLabel.numberOfLines = 0;
        _titleLabel.text = self.titleText;
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(KHHAlertView_Padding, KHHAlertView_Padding, KHHAlertView_Width-KHHAlertView_Padding*2, 0)];
        _detailLabel.numberOfLines = 0;
        _detailLabel.textColor = [UIColor grayColor];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        
        if ([self.detailText containsString:@"emoji"]) {
            //满足日本佬在文字中包含表情的功能
            self.detailLabel.attributedText = [self convertEmojiTextWithText:self.detailText];
        }else{
            [self.detailLabel setText:self.detailText];
        }
        [_detailLabel sizeToFit];
    }
    return _detailLabel;
}

#pragma mark 将文字换成表情
//根据对应的map，将含有表情符号的文本转化成表情
- (NSMutableAttributedString *)convertEmojiTextWithText:(NSString *)text {
    if (!text) {
        NSLog(@"没有数据还做操作？");
        return [NSMutableAttributedString new];
    }
    //正则表达式
    NSString *patternStr = @"emoji";
    
    //字体属性
    UIFont *font = [UIFont systemFontOfSize:17];
    NSDictionary *textAttributes = @{NSFontAttributeName: font};
    //字体行高
    CGFloat attachmentHeight = font.lineHeight;
    
    //转化为
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:text attributes:textAttributes];
    
    //正则对象
    NSError *err;
    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:patternStr options:NSRegularExpressionCaseInsensitive error:&err];
    NSArray *matchStrs = [regularExpression matchesInString:text options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, attributeStr.string.length)];
    
    if (matchStrs.count > 0) {
        for (int i = (int)matchStrs.count-1; i >= 0; i --) {
            NSTextCheckingResult *result = matchStrs[i];
            NSRange range = result.range;
            UIImage *img = [UIImage imageNamed:@"info"];
            
            //创建一个NSTextAttachment
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = img;
            CGFloat attachmentWidth = attachmentHeight * img.size.width/ img.size.height;
            attachment.bounds = CGRectMake(0, (font.capHeight-font.lineHeight)/2, attachmentWidth, attachmentHeight);
            
            //生成NSAttributedString
            NSAttributedString *attstr = [NSAttributedString attributedStringWithAttachment:attachment];
            
            //把字符串替换成表情
            [attributeStr replaceCharactersInRange:range withAttributedString:attstr];
            
        }
    }
    return attributeStr;
}

@end
