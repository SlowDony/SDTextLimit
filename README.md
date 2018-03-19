# SDTextLimit

### 一.`textFiled/textView`限制字符长度
一开始我在做UITextFiled和UITextView限制字数
1.TextFiled限制字数
`[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledChange:) name:UITextFieldTextDidChangeNotification object:nil];`
或者
`[textField addTarget:self action:@selector(textFiledChange:) forControlEvents:UIControlEventEditingChanged];`
然后在

```
-(void)textFiledChange:(UITextFiled *)textFiled{ 

     if(textFiled.text.length > maxNumber)
     {
        textField.text= [textFiled.text substringToIndex:maxNumber];
     }
 
   }
   ```
   也可以在textField的代理中做相应的处理
```
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {} //具体实现和上面方法一样就不多说了
```

2.TextView限制字数
在TextView的代理中
```
- (void)textViewDidChange:(UITextView *)textView{
   if(textView.text.length > maxNumber) 
   {
      textView.text= [textView.text substringToIndex:maxNumber];
   }
}
```
以上方法是最简单的处理,如果输入英文字符完全没有问题,但是输入中文时,如果使用第三方键盘也是没有问题的,但就是在系统自带键盘输入拼音时,你就会发现有很严重的问题😂,当你输入一个拼音时,你还没有选中你要选的文字时,已经被键盘当做字母输入到`textFiled/textView`中了,这并不是你想要的结果...比如你用系统键盘输入"你好",它会把n i h a o显示在`textFiled/textView`中, 不但没有输入汉字,还每个字母占两个字符长度...

分析一下当你输入拼音时,此时你输入的拼音还是处于高亮状态,这时已经走截取字符的方法,截取完又赋值给`textFiled/textView`,所以就会出现以上的问题,处理方法就是监听系统键盘输入拼音处于高亮状态时不截取字符
```
/**
 textFiled限制字数
 */
- (void)textFiledChange:(UITextField *)textField{
    NSInteger maxNumber = 15;
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
        MyLog(@"haha ");
        
        if(toBeString.length > maxNumber) {
           // textField.text= [toBeString substringToIndex:maxNumber];
           //3月19日更新
           //防止表情被截段
             textField.text = [[self class] subStringWith:toBeString index:maxNumber];
        }
    }
}
//textView同上处理
```
完美解决使用系统键盘输入汉字出现的截取拼音字母显示在`textFiled/textView`中

以上处理一般`textFiled/textView`限制字数长度

### 二.`textFiled/textView`限制输入特殊字符

```
/**
 限制输入emoji表情
 */
+ (NSString *)disable_emoji:(NSString *)text{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}

```
```
/**
 只能输入汉字，数字，英文，括号，下划线，横杠，空格
 */
+(NSString *)filterCharactors:(NSString *)string{
    
    NSString *regular = @"[^a-zA-Z0-9()_\u4E00-\u9FA5\\s-]"; //根据你不同的需求填写你自己的正则
    NSString *str = [[self class] filterCharactor:string withRegex:[NSString stringWithFormat:@"%@",regular]];
    return str;
}
```
原理是当字符串判断是否输入你要限制的字符,把要限制的字符截掉
但是当你的`textFiled/textView`既要限制字数,又要限制输入特殊字符,把上面两个方法调完,你会发现,第一个问题又出来了,而且这次是第一次用系统键盘输入汉字时正常,如果你要继续在输入时依然会把拼音当成字符输入到`textFiled/textView`里.所以对上面的方法再次进行优化
### 三.`textFiled/textView`限制字符长度并且限制输入特殊字符
```
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
```
```
/**
 判断是否存在特殊字符 只能输入汉字，数字，英文，括号，下划线，横杠，空格
 */
+ (BOOL)isContainsSpecialCharacters:(NSString *)searchText
{
/*此方法也可以理论上可以,但实测还是会有问题*/
//    NSString *regex = @"[^a-zA-Z0-9()_\u4E00-\u9FA5\\s-]";
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//    BOOL isValid = [predicate evaluateWithObject:string];
//    return isValid; 
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^a-zA-Z0-9()_\u4E00-\u9FA5\\s-]"  options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *result = [regex firstMatchInString:searchText options:0 range:NSMakeRange(0, [searchText length])];
    if (result) {
        return YES;
    }else {
        return NO;
    }
    
}

```
```
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
        MyLog(@"haha ");
        
        if(toBeString.length > maxNumber) {
            //textField.text= [toBeString substringToIndex:maxNumber];
            //3月19日更新
            //防止表情被截段
            textField.text = [[self class] subStringWith:toBeString index:maxNumber];
          }
    }
    
}
```
最终方法
```
/**
 除去特殊字符并限制字数的textFiled
 */
+ (void)restrictionInputTextFieldMaskSpecialCharacter:(UITextField *)textField maxNumber:(NSInteger)maxNumber{
    
    if ([[self class]isContainsEmoji:textField.text]){
        textField.text = [[self class]disable_emoji:textField.text];
        return;
    }
    if ([[self class]isContainsSpecialCharacters:textField.text]){
        textField.text = [[self class]filterCharactors:textField.text];
        return;
    }
    [[self class]restrictionInputTextField:textField maxNumber:maxNumber];
}
```
UITextView同上方法

最最后......


最近测试妹子给测出一个问题,就是我的一个输入框是填写电话的,我的 `keyboardType` 是` UIKeyboardTypePhonePad`.理论上只能输入数字了,于是我也就偷懒没做任何判断屏蔽特殊字符,但是依然给我测出可以输入emoji表情和一些特殊字符,🤣,然后我就想应该是在其他地方复制粘贴到我的`textFiled`里吧,于是我就想到很粗鲁的方法,就是把`textFiled`的粘贴给禁掉🤔 哈哈,以下方法不建议采用,还是老老实实的吧限制特殊字符吧,但是你非要和我一样懒😂,那我也管不着🙄
```
//屏蔽textFiled粘贴
//Initialzation code
        UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(addGestureRecognizer:)];
        longRecognizer.allowableMovement = 100.0f;
        longRecognizer.minimumPressDuration = 1.0;
        [self addGestureRecognizer:longRecognizer];

//重写        
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        //设置为不可用
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}


- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    //Prevent zooming but not panning
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        gestureRecognizer.enabled = NO;
    }
    [super addGestureRecognizer:gestureRecognizer];
}

```


如果你还有其他好的方法欢迎提出,共同学习,peace!

参考[这篇文章](http://zeeyang.com/2015/09/17/TextField_count_limit_handle/)

# 3月19更新

```
//防止原生emoji表情被截断
+ (NSString *)subStringWith:(NSString *)string index:(NSInteger)index{

    NSString *result = string;
    if (result.length > index) {
        NSRange rangeIndex = [result rangeOfComposedCharacterSequenceAtIndex:index];
        result = [result substringToIndex:(rangeIndex.location)];
    }

    return result;
}
```


