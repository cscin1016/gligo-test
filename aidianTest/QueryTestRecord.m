//
//  QueryTestRecord.m
//  aidianTest
//
//  Created by 陈双超 on 2019/9/26.
//  Copyright © 2019 陈双超. All rights reserved.
//

#import "QueryTestRecord.h"
#import "NetWork.h"
#import "RecordCell.h"

#define queueMainStart dispatch_async(dispatch_get_main_queue(), ^{
#define queueEnd  });

static NSString *RecordCellIdentifier = @"RecordCell";

@interface QueryTestRecord () {
    NSMutableArray *recordArray;
}
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *SNLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation QueryTestRecord
@synthesize UUIDStr;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSDictionary *parameters = @{@"uuid": UUIDStr};
    NSLog(@"_UUIDStr:%@",UUIDStr);

    [[NetWork sharedInstance] postDataWithUrl:@"dmf/test/query" parameters:parameters success:^(NSURLSessionDataTask * task , id responseObject) {
        NSLog(@"请求成功：%@",responseObject);
        self->recordArray = [NSMutableArray arrayWithArray:responseObject[@"retData"]];
        queueMainStart
        [self->_myTableView reloadData];
        queueEnd
    } failure:^(NSError *error) {
        NSLog(@"请求失败");
    }];
}

- (IBAction)goBackAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return recordArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RecordCell *cell = [tableView dequeueReusableCellWithIdentifier:RecordCellIdentifier];
    if(cell == nil) {
        cell = [[RecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RecordCellIdentifier];
    }
    NSDictionary *dataModel = recordArray[indexPath.row];
    cell.chargeLabel.text = [NSString stringWithFormat:@"电量：%@%%",dataModel[@"voltage"]];
    cell.chargeLabel.backgroundColor = [UIColor greenColor];
    if ([dataModel[@"gsensor"] intValue]==1) {
        cell.gsensorLabel.text = @"gsensor:正常";
        cell.gsensorLabel.backgroundColor = [UIColor greenColor];
    }else {
        cell.gsensorLabel.text = @"gsensor:不正常";
        cell.gsensorLabel.backgroundColor = [UIColor redColor];
    }
    if ([dataModel[@"step"] intValue]==1) {
        cell.stepLabel.text = @"计步:正常";
        cell.stepLabel.backgroundColor = [UIColor greenColor];
    }else {
        cell.stepLabel.text =@"计步:不正常";
        cell.stepLabel.backgroundColor = [UIColor redColor];
    }
    if ([dataModel[@"screen"] intValue]==1) {
        cell.screenLabel.text = @"屏幕显示:正常";
        cell.screenLabel.backgroundColor = [UIColor greenColor];
    }else {
        cell.screenLabel.text = @"屏幕显示:不正常";
        cell.screenLabel.backgroundColor = [UIColor redColor];
    }
    if ([dataModel[@"motor"] intValue]==1) {
        cell.shockLabel.text = @"震动:正常";
        cell.shockLabel.backgroundColor = [UIColor greenColor];
    }else {
        cell.shockLabel.text =@"震动:不正常";
        cell.shockLabel.backgroundColor = [UIColor redColor];
    }
    
    if ([dataModel[@"pointer"] intValue]==1) {
        cell.pointerLabel.text = @"指针走时:正常";
        cell.pointerLabel.backgroundColor = [UIColor greenColor];
    }else {
        cell.pointerLabel.text =@"指针走时:不正常";
        cell.pointerLabel.backgroundColor = [UIColor redColor];
    }
    
    if ([dataModel[@"heartBeat"] intValue]==1) {
        cell.heartLabel.text = @"心率:正常";
        cell.heartLabel.backgroundColor = [UIColor greenColor];
    }else {
        cell.heartLabel.text =@"心率:不正常";
        cell.heartLabel.backgroundColor = [UIColor redColor];
    }
    
    cell.timeDifferenceLabel.text = [NSString stringWithFormat:@"测试员:%@,时间:%@",dataModel[@"tester"],dataModel[@"testTime"]];
    cell.timeDifferenceLabel.backgroundColor = [UIColor greenColor];

    return cell;
}

@end
