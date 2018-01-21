//
//  SDTextLimitTool.m
//  SDTextLimit
//
//  Created by slowdony on 2018/1/21.
//  Copyright © 2018年 slowdony. All rights reserved.
//

#import "SDTextLimitTool.h"

@implementation SDTextLimitTool

/**
 判断NSString中是否有表情
 */
+ (BOOL)isContainsEmoji:(NSString *)string {
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        const unichar hs = [substring characterAtIndex:0];
        // surrogate pair
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    isEomji = YES;
                }
            }
        } else {
            // non surrogate
            if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                if (!(9312 <= hs && hs <= 9327)) { // 9312代表①   表示①至⑯
                    isEomji = YES;
                }
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                isEomji = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                isEomji = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                isEomji = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                isEomji = YES;
            }
            if (!isEomji && substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                if (ls == 0x20e3) {
                    isEomji = YES;
                }
            }
        }
    }];
    return isEomji;
}

/**
 删除emoji表情
 */
+ (NSString *)disableEmoji:(NSString *)text{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}

/**
 只能输入汉字，数字，英文，括号，下划线，横杠，空格
 */
+(NSString *)filterCharactors:(NSString *)string{
    
    NSString *regular = @"[^a-zA-Z0-9()_\u4E00-\u9FA5\\s-]"; //
    NSString *str = [[self class] filterCharactor:string withRegex:[NSString stringWithFormat:@"%@",regular]];
    
    return str;
}

/**
 判断是否存在特殊字符 只能输入汉字，数字，英文，括号，下划线，横杠，空格
 */
+ (BOOL)isContainsSpecialCharacters:(NSString *)searchText
{
    //    NSString *regex = @"[^a-zA-Z0-9()_\u4E00-\u9FA5\\s-]";
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    //    BOOL isValid = [predicate evaluateWithObject:string];
    //    return isValid;
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z0-9()_\u4E00-\u9FA5\\s-]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *result = [regex firstMatchInString:searchText options:0 range:NSMakeRange(0, [searchText length])];
    if (result) {
        return YES;
    }else {
        return NO;
    }
    
}


/**
 根据正则过滤特殊字符
 */
+ (NSString *)filterCharactor:(NSString *)string withRegex:(NSString *)regexStr{
    NSString *searchText = string;
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *result = [regex stringByReplacingMatchesInString:searchText options:NSMatchingReportCompletion range:NSMakeRange(0, searchText.length) withTemplate:@""];
    return result;
}


/**
 除去特殊字符并限制字数的textFiled
 */
+ (void)restrictionInputTextFieldMaskSpecialCharacter:(UITextField *)textField maxNumber:(NSInteger)maxNumber{
    
    if ([[self class]isContainsEmoji:textField.text]){
        textField.text = [[self class]disableEmoji:textField.text];
        return;
    }
    if ([[self class]isContainsSpecialCharacters:textField.text]){
        textField.text = [[self class]filterCharactors:textField.text];
        return;
    }
    [[self class]restrictionInputTextField:textField maxNumber:maxNumber];
}
/**
 除去特殊字符并限制字数的TextView
 */
+ (void)restrictionInputTextViewMaskSpecialCharacter:(UITextView *)textView maxNumber:(NSInteger)maxNumber{
    
    if ([[self class]isContainsEmoji:textView.text]){
        textView.text = [[self class]disableEmoji:textView.text];
        return;
    }
    if ([[self class]isContainsSpecialCharacters:textView.text]){
        textView.text = [[self class]filterCharactors:textView.text];
        return;
    }
    [[self class]restrictionInputTextView:textView maxNumber:maxNumber];
}

/**
 textFiled限制字数
 */
+ (void)restrictionInputTextField:(UITextField *)textField maxNumber:(NSInteger)maxNumber{
    
    NSString *toBeString = textField.text;
    NSString *lang = textField.textInputMode.primaryLanguage; // 键盘输入模式
    if([lang isEqualToString:@"zh-Hans"]) { //简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if(!position) {
            
            if(toBeString.length > maxNumber) {
                textField.text = [toBeString substringToIndex:maxNumber];
            }
        } else{ //有高亮选择的字符串，则暂不对文字进行统计和限制
            
        }
    }
    else{ //中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        
        if(toBeString.length > maxNumber) {
            textField.text= [toBeString substringToIndex:maxNumber];
        }
    }
    
}

/**
 textView限制字数
 */
+ (void)restrictionInputTextView:(UITextView *)textView maxNumber:(NSInteger)maxNumber{
    
    NSString *toBeString = textView.text;
    NSString *lang = textView.textInputMode.primaryLanguage; // 键盘输入模式
    if([lang isEqualToString:@"zh-Hans"]) { //简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if(!position) {
            if(toBeString.length > maxNumber) {
                textView.text = [toBeString substringToIndex:maxNumber];
            }
        } else{ //有高亮选择的字符串，则暂不对文字进行统计和限制
        }
    } else{ //中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if(toBeString.length > maxNumber) {
            textView.text= [toBeString substringToIndex:maxNumber];
            
        }
    }
}
@end
