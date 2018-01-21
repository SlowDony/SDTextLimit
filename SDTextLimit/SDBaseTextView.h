//
//  SDBaseTextView.h
//  miaohu
//
//  Created by Megatron Joker on 2017/4/20.
//  Copyright © 2017年 SlowDony. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDBaseTextView : UITextView

/**
 *  占位文字
 */
@property (nonatomic, copy) NSString *placeholder;
/**
 *  占位文字颜色
 */
@property (nonatomic, strong) UIColor *placeholderColor;
@end
