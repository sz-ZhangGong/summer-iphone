//
//  MainViewController.m
//  e-Healthy
//
//  Created by FangLin on 16/11/2.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import "MainViewController.h"
#import "LoginViewController.h"
#import "SDCycleScrollView.h"
#import "MainFirstTableViewCell.h"
#import "MainSecondTableViewCell.h"
#import "MainThirdTableViewCell.h"
#import "MainFourthTableViewCell.h"
#import "SearchView.h"

static NSString *const firstCell = @"firstCell";
static NSString *const secondCell = @"secondCell";
static NSString *const thirdCell = @"thirdCell";
static NSString *const fourthCell = @"fourthCell";

@interface MainViewController ()<MainSecondTableViewCell,MainFirstTableViewCell,SDCycleScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)SearchView *searchView;

@end

@implementation MainViewController

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = RGBColor(248, 248, 248, 1.0);
    }
    return _tableView;
}

-(SearchView *)searchView
{
    if (!_searchView) {
        _searchView = [[SearchView alloc] initWithFrame:CGRectMake(15, 15, screen_width-30, 40)];
        _searchView.backgroundColor = [UIColor whiteColor];
        _searchView.alpha = 0.7f;
        _searchView.layer.cornerRadius = 5.0f;
        _searchView.layer.masksToBounds = YES;
    }
    return _searchView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = RGBColor(248, 248, 248, 1.0);
    //设置标题
    [self setNavTitle:@"首页"];
    [self settableheaderView];
    [self settablefooterView];
    [self registerCell];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

//注册cell
-(void)registerCell
{
    [self.tableView registerNib:[UINib nibWithNibName:@"MainFirstTableViewCell" bundle:nil] forCellReuseIdentifier:firstCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"MainSecondTableViewCell" bundle:nil] forCellReuseIdentifier:secondCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"MainThirdTableViewCell" bundle:nil] forCellReuseIdentifier:thirdCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"MainFourthTableViewCell" bundle:nil] forCellReuseIdentifier:fourthCell];
}

//头部广告视图
-(void)settableheaderView
{
    [self.view addSubview:self.tableView];
    NSMutableArray *imageArr = [[NSMutableArray alloc] init];
    for (int i = 0; i<4; i++) {
        [imageArr addObject:[NSString stringWithFormat:@"img_main_midadv0%d",i+1]];
    }
    //初始化广告视图
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, screen_width, 200) delegate:self placeholderImage:[UIImage imageNamed:@"img_main_midadv01"]];
    cycleScrollView.imageURLStringsGroup = imageArr;
    self.tableView.tableHeaderView = cycleScrollView;
    [cycleScrollView addSubview:self.searchView];
    self.searchView.searchTF.delegate = self;
}

//尾部视图
-(void)settablefooterView
{
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 40)];
    footView.backgroundColor = RGBColor(248, 248, 248, 1.0);
    
    UILabel *footLabel = [[UILabel alloc] initWithFrame:CGRectMake(screen_width/2 - 30, 0, 60, footView.current_h)];
    footLabel.text = @"到底啦...";
    footLabel.textColor = RGBColor(200, 200, 200, 1.0);
    footLabel.textAlignment = NSTextAlignmentCenter;
    footLabel.font = [UIFont systemFontOfSize:13];
    [footView addSubview:footLabel];
    
    UILabel *lineOneLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, footView.current_h/2, screen_width/2-20-footLabel.current_w/2, 1)];
    lineOneLabel.backgroundColor = RGBColor(240, 240, 240, 1.0);
    [footView addSubview:lineOneLabel];
    
    UILabel *lineTwoLabel = [[UILabel alloc] initWithFrame:CGRectMake(footLabel.current_x_w+10, footView.current_h/2, lineOneLabel.current_w, 1)];
    lineTwoLabel.backgroundColor = RGBColor(240, 240, 240, 1.0);
    [footView addSubview:lineTwoLabel];
    self.tableView.tableFooterView = footView;
}

#pragma mark - MainSecondTableViewCell 代理方法
-(void)tapClick:(NSInteger)number
{
    if (number == 1) {
        NSLog(@"点击了第一个视图");
    }else if (number == 2){
        NSLog(@"点击了第二个视图");
    }
}

#pragma mark - MainFirstTableViewCell 代理方法
-(void)firstTapClick:(NSInteger)number
{
    if (number == 1) {
        NSLog(@"点击了病历");
    }else if (number == 2){
        NSLog(@"点击了挂号");
    }else if (number == 3){
        NSLog(@"点击了新农合");
    }
}

#pragma mark - UITableView Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }else{
        return 4;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            MainFirstTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:firstCell forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            return cell;
        }else if (indexPath.row == 1){
            MainSecondTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:secondCell forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            return cell;
        }
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            MainThirdTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:thirdCell forIndexPath:indexPath];
            return cell;
        }else{
            MainFourthTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:fourthCell forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            return cell;
        }
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 80;
        }else if (indexPath.row == 1){
            return 90;
        }
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            return 40;
        }else{
            return 80;
        }
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 点击事件
//登录入口
-(void)seachDidClick
{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
