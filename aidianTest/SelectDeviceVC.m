//
//  SelectDeviceVC.m
//  aidianTest
//
//  Created by 陈双超 on 2019/9/22.
//  Copyright © 2019 陈双超. All rights reserved.
//

#import "SelectDeviceVC.h"
#import "BLEManager.h"

@interface SelectDeviceVC ()
@property (weak, nonatomic) IBOutlet UIButton *ButtonOne;
@property (weak, nonatomic) IBOutlet UIButton *ButtonTwo;
@property (weak, nonatomic) IBOutlet UIButton *ButtonThree;
@property (weak, nonatomic) IBOutlet UIButton *ButtonFour;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation SelectDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _ButtonOne.titleLabel.numberOfLines = 0;
    _ButtonTwo.titleLabel.numberOfLines = 0;
    _ButtonThree.titleLabel.numberOfLines = 0;
    _ButtonFour.titleLabel.numberOfLines = 0;
    _nextButton.enabled = NO;
}

- (IBAction)goBackAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectWatchTypeAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (_ButtonOne.selected||_ButtonTwo.selected||_ButtonThree.selected||_ButtonFour.selected) {
        _nextButton.enabled = YES;
    }else {
        _nextButton.enabled = NO;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSMutableArray *tempArray = [NSMutableArray new];
    if (_ButtonOne.selected) {
        [tempArray addObject:@"GliGO Watch One"];
    }
    if (_ButtonTwo.selected) {
        [tempArray addObject:@"GliGO Watch One Plus"];
    }
    if (_ButtonThree.selected) {
        [tempArray addObject:@"GLAGOM ONE"];
    }
    [BLEManager sharedManager].supportDeviceList = tempArray;
}


@end
