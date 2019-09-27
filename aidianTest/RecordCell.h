//
//  RecordCell.h
//  aidianTest
//
//  Created by 陈双超 on 2019/9/26.
//  Copyright © 2019 陈双超. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *chargeLabel;
@property (weak, nonatomic) IBOutlet UILabel *gsensorLabel;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenLabel;
@property (weak, nonatomic) IBOutlet UILabel *shockLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointerLabel;
@property (weak, nonatomic) IBOutlet UILabel *heartLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeDifferenceLabel;

@end

NS_ASSUME_NONNULL_END
