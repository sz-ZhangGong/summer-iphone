//
//  PingImageViewController.m
//  summer
//
//  Created by FangLin on 1/14/17.
//  Copyright © 2017 FangLin. All rights reserved.
//

#import "PingImageViewController.h"
#import "CustemNavItem.h"
#import "DisplayUtils.h"
#import "UIImageView+WebCache.h"

@interface PingImageViewController ()<CustemBBI,UIGestureRecognizerDelegate>
{
    CGSize size;
}
@property (nonatomic,strong)UIImageView *imageView;

@end

@implementation PingImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.view.contentMode = UIViewContentModeCenter;
    //设置导航栏的按钮
    self.navigationItem.leftBarButtonItem = [CustemNavItem initWithImage:[UIImage imageNamed:@"ic_nav_back"] andTarget:self andinfoStr:@"first"];
    size = [DisplayUtils getImageSizeWithURL:_imageStr];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    self.imageView.center = self.view.center;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:_imageStr] placeholderImage:nil];
    [self.view addSubview:self.imageView];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleImage:)];
    [pinchRecognizer setDelegate:self];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:pinchRecognizer];
    
    //平移
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:1];
    [self.imageView addGestureRecognizer:panGesture];
}

- (void) scaleImage:(UIPinchGestureRecognizer*)pinchGestureRecognizer
{
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        _imageView.transform = CGAffineTransformScale(_imageView.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
}


- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGestureRecognizer translationInView:_imageView.superview];
        [_imageView setCenter:(CGPoint){_imageView.center.x + translation.x, _imageView.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:_imageView.superview];
    }
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
