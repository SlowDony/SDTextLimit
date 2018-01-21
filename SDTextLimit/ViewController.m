//
//  ViewController.m
//  SDTextLimit
//
//  Created by slowdony on 2018/1/21.
//  Copyright © 2018年 slowdony. All rights reserved.
//

#import "ViewController.h"
#import "SDTextViewController.h"
@interface ViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>
/**
 列表
 */
@property (nonatomic,strong) UITableView    *  tableView;

/**
 数据源
 */
@property (nonatomic,strong) NSMutableArray *  dataArr;

@end

@implementation ViewController

#pragma mark - lazy
-(NSMutableArray *)dataArr{
    if (!_dataArr){
        NSArray *arr = @[
                     @"textField限制字数",
                     @"textView限制字数",
                     ];
        
        _dataArr = [NSMutableArray arrayWithArray:arr];
    }
    return _dataArr;
}
-(UITableView *)tableView{
    if (!_tableView){
        //
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        
    }
    return _tableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"SDTextLimit";
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.tableView];
}

#pragma mark ----------UITabelViewDataSource----------
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self.dataArr count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    //配置数据
    cell.textLabel.text = self.dataArr[indexPath.row];
    
    return cell;
}


#pragma mark ----------UITabelViewDelegate----------
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SDTextViewController *textVC = [[SDTextViewController alloc]init];
    textVC.textViewVCType = indexPath.row;
    [self.navigationController pushViewController:textVC animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
