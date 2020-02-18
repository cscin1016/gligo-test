//
//  EPDPOPControlVC.m
//  aidianTest
//
//  Created by 陈双超 on 2020/2/13.
//  Copyright © 2020 陈双超. All rights reserved.
//

#import "EPDPOPControlVC.h"
#import "ScreenView.h"
#import "TimeSelecter.h"
#import "BLEManager.h"
#import "PopupView.h"

@interface EPDPOPControlVC (){
    char dollarShow;
    char dotShow;
    char numberShow;
    char forsShow;
    double priceValue;
}
@property (weak, nonatomic) IBOutlet UIImageView *dollarImg;
@property (weak, nonatomic) IBOutlet UIImageView *numberImg;
@property (weak, nonatomic) IBOutlet UIImageView *forImg;
@property (weak, nonatomic) IBOutlet UIImageView *oneNumberImg;
@property (weak, nonatomic) IBOutlet UIImageView *twoNumberImg;
@property (weak, nonatomic) IBOutlet UIImageView *threeNumberImg;
@property (weak, nonatomic) IBOutlet UIImageView *fourNumberImg;

@property (weak, nonatomic) IBOutlet ScreenView *screenView;

@property (strong, nonatomic) TimeSelecter *timeSelector;

@property (weak, nonatomic) IBOutlet UILabel *animationLabel;

@end

@implementation EPDPOPControlVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dollarShow = 1;
    forsShow = 1;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //获取触摸点的集合
    NSSet * allTouches = [event allTouches];
    //获取触摸对象
    UITouch * touch = [allTouches anyObject];
    //返回触摸点所在视图中的坐标
    CGPoint point = [touch locationInView:_screenView];
    NSLog(@"point--x:%f y:%f",point.x,point.y);
    //美元符检测
    if(0<point.x&&point.x<50 && 8<point.y&&point.y<68){
        _dollarImg.hidden = !_dollarImg.hidden;
        if (_dollarImg.hidden) {
            dollarShow = 0;
        }else {
            dollarShow = 1;
        }
        [self sendPriceAction];
    }
    if(8<point.x&&point.x<58 && 76<point.y&&point.y<136){
        [self setNumberAction];
    }
    if(58<point.x&&point.x<108 && 76<point.y&&point.y<136){
        _forImg.hidden = !_forImg.hidden;
        if (_forImg.hidden) {
            forsShow = 0;
        }else {
            forsShow = 1;
        }
        [self sendPriceAction];
    }
    if (108<point.x&&point.x<308 && 24<point.y&&point.y<128) {
        [self setPriceNumberAction];
    }
}

- (void)sendPriceAction {
    [[BLEManager sharedManager] setPriceCommand:numberShow dot:dotShow usa:dollarShow forS:forsShow priceNumber:priceValue];
}

- (void)setNumberAction{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"请输入商品数量" preferredStyle:UIAlertControllerStyleAlert];
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }]];

    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取第1个输入框
        UITextField *userNameTextField = alertController.textFields.firstObject;
        NSLog(@"个数 = %@",userNameTextField.text);
        if ( userNameTextField.text.length != 1) {
            [self showTipAction:@"输入内容无效，请重新操作"];
        }else if ( [userNameTextField.text isEqualToString:@"0"]) {
            self->_numberImg.hidden = YES;
            self->numberShow = 0xff;
            [self sendPriceAction];
        }else if(userNameTextField.text.intValue < 10 && userNameTextField.text.intValue >0){
            self->_numberImg.hidden = NO;
            self->_numberImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"number%d",userNameTextField.text.intValue]];
            self->numberShow = userNameTextField.text.intValue;
            [self sendPriceAction];
        }else {
            [self showTipAction:@"输入内容无效，请重新操作"];
        }
        
    }]];
    //定义第一个输入框；
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入1-9有效,0隐藏";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)showTipAction:(NSString *)comtentStr {
    PopupView  *popUpView;
    popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 240, 0, 0)];
    popUpView.ParentView = self.view;
    [popUpView setText: comtentStr];
    [self.view addSubview:popUpView];
}

- (void)setPriceNumberAction {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"请输入商品价格" preferredStyle:UIAlertControllerStyleAlert];
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }]];

    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取第1个输入框
        UITextField *userNameTextField = alertController.textFields.firstObject;
        NSLog(@"个数 = %@",userNameTextField.text);
        if ( userNameTextField.text.doubleValue > 1999  ) {
            [self showTipAction:@"输入内容无效，请重新操作"];
        }else if ( [userNameTextField.text isEqualToString:@"0"]) {
            self->_oneNumberImg.hidden = YES;
            self->_twoNumberImg.hidden = YES;
            self->_threeNumberImg.hidden = YES;
            self->_fourNumberImg.hidden = YES;
            self->dotShow = 0;
            NSLog(@"小数点隐藏");
            self->priceValue = 0;
            [self sendPriceAction];
        }else if(userNameTextField.text.doubleValue < 100 && userNameTextField.text.doubleValue >0){
            if(userNameTextField.text.doubleValue < 10){
                self->_oneNumberImg.hidden = YES;
            }else {
                self->_oneNumberImg.hidden = NO;
            }
            self->_twoNumberImg.hidden = NO;
            self->_threeNumberImg.hidden = NO;
            self->_fourNumberImg.hidden = NO;
            self->_oneNumberImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"number%d",userNameTextField.text.intValue/10]];
            self->_twoNumberImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"number%d",userNameTextField.text.intValue%10]];
            self->_threeNumberImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"number%d",((int)(userNameTextField.text.doubleValue*10))%10]];
            self->_fourNumberImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"number%d",((int)(userNameTextField.text.doubleValue*100))%10]];
            self->dotShow = 1;
            NSLog(@"小数点显示");
            self->priceValue = userNameTextField.text.doubleValue;
            [self sendPriceAction];
        }else if(userNameTextField.text.doubleValue < 1000 && userNameTextField.text.doubleValue >=100){
            self->_oneNumberImg.hidden = YES;
            self->_twoNumberImg.hidden = NO;
            self->_threeNumberImg.hidden = NO;
            self->_fourNumberImg.hidden = NO;
            self->_twoNumberImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"number%d",userNameTextField.text.intValue/100]];
            self->_threeNumberImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"number%d",userNameTextField.text.intValue/10%10]];
            self->_fourNumberImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"number%d",userNameTextField.text.intValue%10]];
            self->dotShow = 0;
            NSLog(@"小数点隐藏");
            self->priceValue = userNameTextField.text.intValue;
            [self sendPriceAction];
        }else {
            self->_oneNumberImg.hidden = NO;
            self->_twoNumberImg.hidden = NO;
            self->_threeNumberImg.hidden = NO;
            self->_fourNumberImg.hidden = NO;
            self->_oneNumberImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"number%d",userNameTextField.text.intValue/1000]];
            self->_twoNumberImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"number%d",userNameTextField.text.intValue/100%10]];
            self->_threeNumberImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"number%d",userNameTextField.text.intValue/10%10]];
            self->_fourNumberImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"number%d",userNameTextField.text.intValue%10]];
            self->dotShow = 0;
            NSLog(@"小数点隐藏");
            self->priceValue = userNameTextField.text.intValue;
            [self sendPriceAction];
        }
        
    }]];
    //定义第一个输入框；
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入0-1999,支持两位小数";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }];
    [self presentViewController:alertController animated:true completion:nil];
    
}

- (IBAction)animationSetAction:(UIButton *)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"模式切换" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    // 创建action，这里action1只是方便编写，以后再编程的过程中还是以命名规范为主
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"预设演示模式一" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"预设演示模式一");
        [[BLEManager sharedManager] setShowModelAction:1];
        self->_animationLabel.text = @"动画一";
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"预设演示模式二" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"预设演示模式二");
        [[BLEManager sharedManager] setShowModelAction:2];
        self->_animationLabel.text = @"动画二";
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"价格牌模式" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"价格牌模式");
        [[BLEManager sharedManager] setShowModelAction:0];
        self->_animationLabel.text = @"价格牌";
    }];
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"取消");
    }];
    //把action添加到actionSheet里
    [actionSheet addAction:action1];
    [actionSheet addAction:action2];
    [actionSheet addAction:action3];
    [actionSheet addAction:action4];
    
    //相当于之前的[actionSheet show];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

@end
