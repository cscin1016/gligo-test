//
//  AppDelegate.h
//  aidianTest
//
//  Created by 陈双超 on 2019/5/8.
//  Copyright © 2019 陈双超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHAlertViewConst.h"
#import "UIView+Draw.h"

@protocol HHAlertViewDelegate;


typedef NS_ENUM(NSInteger, HHAlertViewMode){
    HHModeDefault,
    HHModeCustom,
    HHModeLogoOne,
    HHModeLogoTwo,
    HHModeLogoThree,
    HHModeRadioSelect
};

typedef void (^selectButtonIndexComplete)(NSInteger index, NSInteger radioindex);

@interface HHAlertView : UIView

@property (nonatomic, weak)   id<HHAlertViewDelegate> delegate;

@property (nonatomic, copy)   selectButtonIndexComplete completeBlock;

@property (nonatomic, assign) HHAlertViewMode mode;

@property (nonatomic, copy)   NSString *titleText;

@property (nonatomic, copy)   NSString *detailText;

@property (nonatomic, strong) UIView *customView;

@property (nonatomic, copy)   NSString  *cancelButtonTitle;

@property (nonatomic, strong) NSArray   *otherButtonTitles;

@property (nonatomic, assign) BOOL removeFromSuperViewOnHide;

- (instancetype)initWithTitle:(NSString *)title
                   detailText:(NSString *)detailtext
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray  *)otherButtonsTitles;

- (void)hide;

- (void)show;

- (void)showWithBlock:(selectButtonIndexComplete)completeBlock;

@end



@protocol HHAlertViewDelegate <NSObject>

@optional
/**
 *  the delegate to tell user whitch button is clicked
 *
 *  @param buttonIndex button
 */
- (void)HHAlertView:(HHAlertView *)alertview didClickButtonAnIndex:(NSInteger )buttonIndex;

@end

