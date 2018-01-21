//
//  SDTextViewController.h
//  SDTextLimit
//
//  Created by slowdony on 2018/1/21.
//  Copyright © 2018年 slowdony. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger ,TextViewVCType) {
    TextViewVCTypeTextFiledNum, //TextFiled限制字数
    TextViewVCTypeTextFiledNumCharacter, //TextFiled限制字数和特殊字符
    TextViewVCTypeTextViewNum, //TextView限制字数
    TextViewVCTypeTextViewNumCharacter //TextView限制字数和特殊字符
};

@interface SDTextViewController : UIViewController
@property (nonatomic,assign)  TextViewVCType textViewVCType;//
@property (nonatomic,copy)  NSString  *placeholder;
@end
