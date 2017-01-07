//
//  SettingViewController.m
//  summer
//
//  Created by FangLin on 11/21/16.
//  Copyright © 2016 FangLin. All rights reserved.
//

#import "SettingViewController.h"
#import "DisplayUtils.h"
#import "CustemNavItem.h"
#import "UserDefaultsUtils.h"

@interface SettingViewController ()<CustemBBI>

@property (nonatomic,strong)UISlider *slider;

@property (nonatomic,strong)UILabel *valueLabel;

@property (nonatomic,strong)UIButton *perverseBtn;

@end

@implementation SettingViewController

-(UISlider *)slider
{
    if (!_slider) {
        _slider = [[UISlider alloc] init];
        _slider.frame = CGRectMake(40, 120, screen_width-80, 30);
    }
    return _slider;
}

-(UILabel *)valueLabel
{
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, self.slider.current_y_h+10, 50, 30)];
        _valueLabel.layer.borderWidth = 1.0f;
        _valueLabel.layer.borderColor = [UIColor grayColor].CGColor;
        _valueLabel.layer.masksToBounds = YES;
        _valueLabel.font = [UIFont systemFontOfSize:15];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
        _valueLabel.text = [UserDefaultsUtils valueWithKey:@"scale"];
        _valueLabel.layer.cornerRadius = 15;
        _valueLabel.layer.masksToBounds = YES;
    }
    return _valueLabel;
}

-(UIButton *)perverseBtn
{
    if (!_perverseBtn) {
        _perverseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _perverseBtn.frame = CGRectMake(40, self.valueLabel.current_y_h+20, 70, 35);
        [_perverseBtn setTitle:@"保存" forState:UIControlStateNormal];
        [_perverseBtn setBackgroundColor:RGBColor(200, 200, 200, 1.0)];
        [_perverseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_perverseBtn addTarget:self action:@selector(perverseClick) forControlEvents:UIControlEventTouchUpInside];
        _perverseBtn.layer.cornerRadius = 5;
        _perverseBtn.layer.masksToBounds = YES;
    }
    return _perverseBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setNavTitle:@"设置"];
    //设置导航栏的按钮
    self.navigationItem.leftBarButtonItem = [CustemNavItem initWithImage:[UIImage imageNamed:@"ic_nav_back"] andTarget:self andinfoStr:@"first"];
    [self createUI];
}

-(void)createUI
{
    [self custemSlider];
    [self.view addSubview:self.valueLabel];
    [self.view addSubview:self.perverseBtn];
}

-(void)custemSlider
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, 100, 50)];
    label.text = @"缩放比例:";
    label.font = [UIFont systemFontOfSize:18];
    label.textColor = [UIColor blackColor];
    [self.view addSubview:label];
    
    //定义两张图片
    UIImage *minImage = [DisplayUtils createImageWithColor:RGBColor(32, 178, 170, 1.0) andX:10 andY:10];
    UIImage *maxImage = [DisplayUtils createImageWithColor:RGBColor(55, 57, 85, 1.0) andX:10 andY:10];
    
    UIImage *imageMin = [minImage stretchableImageWithLeftCapWidth:minImage.size.width/2 topCapHeight:minImage.size.height/2];
    UIImage *imageMax = [maxImage stretchableImageWithLeftCapWidth:maxImage.size.width/2 topCapHeight:maxImage.size.height/2];
    //设置拇指图片
    [self.slider setThumbImage:[DisplayUtils createImageWithColor:RGBColor(32, 178, 170, 1.0) andX:20 andY:20] forState:UIControlStateNormal];
    //设置滑竿上拇指，左边和右边的图片
    [self.slider setMinimumTrackImage:imageMin forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:imageMax forState:UIControlStateNormal];
    //添加一个事件，改变self.view的背景颜色
    self.slider.minimumValue = 0;
    self.slider.maximumValue = 1.2;
    self.slider.value = [[UserDefaultsUtils valueWithKey:@"scale"] floatValue];
    [self.slider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.slider];
}

-(void)sliderValueChange:(UISlider *)slider
{
    self.valueLabel.text = [NSString stringWithFormat:@"%.1f",slider.value];
}

#pragma mark - 点击事件
-(void)perverseClick
{
    [UserDefaultsUtils saveValue:self.valueLabel.text forKey:@"scale"];
    if (self.delegate && [self.delegate respondsToSelector:@selector(perverseInfo:)]) {
        [self.delegate perverseInfo:[self.valueLabel.text floatValue]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)BBIdidClickWithName:(NSString *)infoStr
{
    [self.navigationController popViewControllerAnimated:YES];
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
