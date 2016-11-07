//
//  RootViewController.m
//  e-Healthy
//
//  Created by FangLin on 16/11/2.
//  Copyright © 2016年 FangLin. All rights reserved.
//

#import "RootViewController.h"
#import "BaseNavViewController.h"
#import "MainViewController.h"
#import "MessageViewController.h"
#import "MyViewController.h"

@interface RootViewController ()

@property (nonatomic,strong)UITabBarController *tabbarController;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self changeChildControll];
}

-(void)changeChildControll
{
    [self addChildViewController:self.tabbarController];
    [self.view addSubview:self.tabbarController.view];
    [self.tabbarController didMoveToParentViewController:self];
}

//初始化tabbar
-(UITabBarController *)tabbarController
{
    if (_tabbarController==nil) {
        _tabbarController=[[UITabBarController alloc]init];
        NSArray *imageNameArr=@[@"ic_tab_home",@"ic_tab_classify",@"ic_tab_me"];
        NSArray *nameArr=@[@"首页",@"消息",@"我的"];
        MainViewController *main=[[MainViewController alloc]init];
        MessageViewController *message=[[MessageViewController alloc]init];
        MyViewController *myCenter=[[MyViewController alloc]init];
        NSArray *vcArr=@[main,message,myCenter];
        NSMutableArray *array=[[NSMutableArray alloc]init];
        for (NSInteger i=0; i<3; i++) {
            UIViewController *viewController=vcArr[i];
            viewController.view.backgroundColor=[UIColor whiteColor];
            BaseNavViewController *nav=[[BaseNavViewController alloc]initWithRootViewController:viewController];
            nav.navigationBar.barTintColor = RGBColor(45, 160, 173, 1.0);
            UIImage *image=[[UIImage imageNamed:imageNameArr[i]]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            UIImage *image_current=[[UIImage imageNamed:[NSString stringWithFormat:@"%@_pass",imageNameArr[i]]]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            nav.tabBarItem.image=image;
            nav.tabBarItem.title=nameArr[i];
            nav.tabBarItem.selectedImage=image_current;
            [nav.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -5)];
            [nav.tabBarItem setImageInsets:UIEdgeInsetsMake(-4, 0, 4, 0)];
            nav.tabBarItem.selectedImage=image_current;
            
            //登录入口
            UIImage *seachimage=[UIImage imageNamed:@"ic_login_user"];
            UIImageView *seachimageView=[[UIImageView alloc]initWithImage:[seachimage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            seachimageView.frame=CGRectMake(0, 0, seachimage.size.width, seachimage.size.height);
            
            UIBarButtonItem *seachBBI=[[UIBarButtonItem alloc]initWithCustomView:seachimageView];
            seachimageView.userInteractionEnabled=YES;
            UITapGestureRecognizer *seachtap=[[UITapGestureRecognizer alloc]initWithTarget:viewController action:@selector(seachDidClick)];
            [seachimageView addGestureRecognizer:seachtap];
            if (i == 0) {
                viewController.navigationItem.rightBarButtonItem = seachBBI;
            }
            [array addObject:nav];
        }
        [_tabbarController.tabBar setTintColor:RGBColor(120, 200, 190, 1.0)];
        _tabbarController.viewControllers=array;
    }
    return _tabbarController;
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
