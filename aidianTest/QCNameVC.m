//
//  QCNameVC.m
//  aidianTest
//
//  Created by 陈双超 on 2019/9/22.
//  Copyright © 2019 陈双超. All rights reserved.
//

#import "QCNameVC.h"

@interface QCNameVC ()
@property (weak, nonatomic) IBOutlet UITextField *QCNameTF;


@end

@implementation QCNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *oldQCName = [[NSUserDefaults standardUserDefaults] objectForKey:@"QCNameKey"];
    if (oldQCName.length > 0) {
        _QCNameTF.text = oldQCName;
    }
}

- (IBAction)goBackAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    if (_QCNameTF.text.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:_QCNameTF.text forKey:@"QCNameKey"];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_QCNameTF resignFirstResponder];
}


@end
