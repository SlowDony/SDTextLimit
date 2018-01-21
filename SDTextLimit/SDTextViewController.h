//
//  SDTextViewController.h
//  SDTextLimit
//
//  Created by slowdony on 2018/1/21.
//  Copyright © 2018年 slowdony. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger ,TextViewVCType) {
    TextViewVCTypeTextFiled,
    TextViewVCTypeTextView
};

@interface SDTextViewController : UIViewController
@property (nonatomic,assign)  TextViewVCType *textViewVCType;//
@end
