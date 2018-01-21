//
//  SDTextViewController.m
//  SDTextLimit
//
//  Created by slowdony on 2018/1/21.
//  Copyright © 2018年 slowdony. All rights reserved.
//

#import "SDTextViewController.h"
#import "SDBaseTextView.h"
#import "SDTextLimitTool.h"
#define  height  [UIScreen mainScreen].bounds.size.height
#define  width   [UIScreen mainScreen].bounds.size.width
@interface SDTextViewController ()
<UITextFieldDelegate,UITextViewDelegate>


/**
 textView
 */
@property (nonatomic,strong)  SDBaseTextView * textView;
/**
 textFiled
 */
@property (nonatomic,strong)  UITextField *textFiled;


@end

@implementation SDTextViewController

#pragma mark - lazy

-(UITextField *)textFiled{
    if (!_textFiled) {
        _textFiled = [[UITextField alloc] init];
        _textFiled.frame = CGRectMake(20, (height-30)/2, width-40, 30);
        _textFiled.delegate = self;
        _textFiled.tag = 0;
        _textFiled.placeholder = self.placeholder;
        _textFiled.font = [UIFont systemFontOfSize:15];
        _textFiled.textColor =[UIColor blackColor];
        _textFiled.clearButtonMode =  UITextFieldViewModeNever;
        _textFiled.keyboardType = UIKeyboardTypeDefault;
        _textFiled.autocorrectionType = UITextAutocorrectionTypeNo;
        _textFiled.borderStyle = UITextBorderStyleRoundedRect;
        [_textFiled addTarget:self action:@selector(textFiledChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textFiled;
}

-(SDBaseTextView *)textView{
    if (!_textView){
        _textView =[[SDBaseTextView alloc]init];
        _textView.frame =CGRectMake(20, (height-100)/2, width-40, 100);
        _textView.delegate = self;
        _textView.placeholder = self.placeholder;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textColor = [UIColor blackColor];
        _textView.textAlignment = NSTextAlignmentLeft;
        _textView.font = [UIFont systemFontOfSize:15];
        _textView.layer.cornerRadius = 4;
        _textView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:0.8].CGColor;
        _textView.layer.borderWidth = 1;
        _textView.layer.masksToBounds = YES;
    }
    return  _textView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"SDTextViewController";
    self.view.backgroundColor = [UIColor whiteColor];
    if(self.textViewVCType==TextViewVCTypeTextFiledNum || self.textViewVCType == TextViewVCTypeTextFiledNumCharacter){
        [self setupTextFiled];
    }
    else {
        [self setupTextView];
    }
    // Do any additional setup after loading the view.
}

-(void)setupTextFiled{
    [self.view addSubview:self.textFiled];
}

-(void)setupTextView{
    [self.view addSubview:self.textView];
}

- (void)textFiledChanged:(UITextField *)textFiled{
    if (self.textViewVCType == TextViewVCTypeTextFiledNum){
      
    [SDTextLimitTool restrictionInputTextField:textFiled maxNumber:15];
        
    }else {
        [SDTextLimitTool restrictionInputTextFieldMaskSpecialCharacter:textFiled maxNumber:15];
    }
    
    
}

- (void)textViewDidChange:(UITextView *)textView{
    if (self.textViewVCType == TextViewVCTypeTextViewNum){
        [SDTextLimitTool restrictionInputTextView:textView maxNumber:15];
    }else {
        [SDTextLimitTool restrictionInputTextViewMaskSpecialCharacter:textView maxNumber:15];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
