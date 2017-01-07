//
//  ScanTwoViewController.m
//  summer
//
//  Created by FangLin on 1/3/17.
//  Copyright © 2017 FangLin. All rights reserved.
//

#import "ScanTwoViewController.h"
#import "RecogizeCardManager.h"
#import "CustemNavItem.h"

@interface ScanTwoViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,CustemBBI>
{
    UIImagePickerController *imgagePickController;
}
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ScanTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"扫描健康卡";
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    imgagePickController = [[UIImagePickerController alloc] init];
    imgagePickController.delegate = self;
    imgagePickController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    imgagePickController.allowsEditing = YES;
    
    self.navigationItem.leftBarButtonItem = [CustemNavItem initWithImage:[UIImage imageNamed:@"ic_nav_back"] andTarget:self andinfoStr:@"first"];
}

#pragma mark - 导航栏返回
-(void)BBIdidClickWithName:(NSString *)infoStr
{
    if ([infoStr isEqualToString:@"first"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (IBAction)cameraAction:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imgagePickController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imgagePickController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        [self presentViewController:imgagePickController animated:YES completion:nil];
    }else{
        NSLog(@"不能打开相机");
    }
}
- (IBAction)photoAction:(id)sender {
    imgagePickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imgagePickController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSLog(@"==== %@",mediaType);
    UIImage *srcImage = nil;
    //判断资源类型
    if ([mediaType isEqualToString:@"public.image"]) {
        srcImage = info[UIImagePickerControllerEditedImage];
        self.imageView.image = srcImage;
        //识别身份证号
        self.textLabel.text = @"正在识别中...";
        [[RecogizeCardManager recognizeCardManager] recognizeCardWithImage:srcImage compleate:^(NSString *text) {
            if (text != nil) {
                self.textLabel.text = [NSString stringWithFormat:@"识别结果:%@",text];
                NSLog(@"识别结果:%@",text);
            }else{
                self.textLabel.text = @"请选择照片";
                NSLog(@"识别失败");
            }
        }];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
