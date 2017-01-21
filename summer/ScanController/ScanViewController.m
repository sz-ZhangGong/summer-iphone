//
//  lhScanQCodeViewController.m
//  lhScanQCodeTest
//
//  Created by bosheng on 15/10/20.
//  Copyright © 2015年 bosheng. All rights reserved.
//

#import "ScanViewController.h"
#import "FLCodeView.h"
#import "CustemNavItem.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "RecogizeCardManager.h"

#define DeviceMaxHeight ([UIScreen mainScreen].bounds.size.height)
#define DeviceMaxWidth ([UIScreen mainScreen].bounds.size.width)
#define widthRate DeviceMaxWidth/320
#define IOS8 ([[UIDevice currentDevice].systemVersion intValue] >= 8 ? YES : NO)

@interface ScanViewController ()<FLCodeView,AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,CustemBBI>
{
    FLCodeView * readview;//二维码扫描对象
    
    BOOL isFirst;//第一次进入该页面
    BOOL isPush;//跳转到下一级页面
}

@property (strong, nonatomic) CIDetector *detector;

@property (nonatomic,strong)UIImageView *imageView;

@end

@implementation ScanViewController

-(UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 450, 200, 100)];
        
    }
    return _imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavTitle:@"扫描卡号"];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [CustemNavItem initWithString:@"相册" andTarget:self andinfoStr:@"second"];
    //    self.navigationItem.leftBarButtonItem = [CustemNavItem initWithImage:[UIImage imageNamed:@"ic_nav_back"] andTarget:self andinfoStr:@"first"];
    self.navigationItem.leftBarButtonItem = [CustemNavItem initWithImage:[UIImage imageNamed:@"ic_nav_back"] andTarget:self andinfoStr:@"first"];
    
    isFirst = YES;
    isPush = NO;
    
    [self InitScan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 导航栏返回
-(void)BBIdidClickWithName:(NSString *)infoStr
{
    if ([infoStr isEqualToString:@"first"]) {
        [self.navigationController popViewControllerAnimated:YES];
        if (self.delegate && [self.delegate respondsToSelector:@selector(backBar)]) {
            [self.delegate backBar];
        }
    }else if ([infoStr isEqualToString:@"second"]){
        [readview stop];
        [self alumbBtnEvent];
    }
}

#pragma mark 初始化扫描
- (void)InitScan
{
    if (readview) {
        [readview removeFromSuperview];
        readview = nil;
    }
    
    readview = [[FLCodeView alloc]initWithFrame:CGRectMake(0, 0, DeviceMaxWidth, DeviceMaxHeight)];
    readview.is_AnmotionFinished = YES;
    readview.backgroundColor = [UIColor clearColor];
    readview.delegate = self;
    readview.alpha = 0;
    
    [self.view addSubview:readview];
    
    [UIView animateWithDuration:0.5 animations:^{
        readview.alpha = 1;
    }completion:^(BOOL finished) {
        
    }];
//    [self.view addSubview:self.imageView];
}

#pragma mark - 相册
- (void)alumbBtnEvent
{
    self.detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) { //判断设备是否支持相册
        
        if (IOS8) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"未开启访问相册权限，现在去开启！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertController addAction:alertAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备不支持访问相册，请在设置->隐私->照片中进行设置！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertController addAction:alertAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
        return;
    }
    
    isPush = YES;
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = self;
    [self presentViewController:mediaUI animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }];
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSLog(@"==== %@ ",mediaType);
    UIImage *srcImage = nil;
    //判断资源类型
    if ([mediaType isEqualToString:@"public.image"]) {
        srcImage = info[UIImagePickerControllerEditedImage];
        
        NSLog(@"正在识别中...");
        __weak typeof(self) weakSelf = self;
        [[RecogizeCardManager recognizeCardManager] recognizeCardWithImage:srcImage compleate:^(NSString *text) {
            NSString *strUrl = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            if (strUrl != nil && [self isPureInt:strUrl]) {
                NSLog(@"识别结果:%@",strUrl);
                [readview stop];
                [weakSelf accordingQcode:strUrl];
                //播放扫描二维码的声音
//                SystemSoundID soundID;
//                NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"noticeMusic" ofType:@"wav"];
//                AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
//                AudioServicesPlaySystemSound(soundID);
            }else{
                NSLog(@"识别失败");
                [readview start];
            }
        }];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }];
    
}

#pragma mark -QRCodeReaderViewDelegate
- (void)readerScanResult:(UIImage *)result
{
    self.imageView.image = result;
    NSLog(@"=====%@",result);
    readview.is_Anmotion = YES;
    
    @synchronized (self) {
        [NSThread sleepForTimeInterval:1.5f];
        __weak typeof(self) weakSelf = self;
        [[RecogizeCardManager recognizeCardManager] recognizeCardWithImage:result compleate:^(NSString *text) {
            NSString *strUrl = [text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            if (strUrl != nil && [self isPureInt:strUrl]) {
                NSLog(@"识别结果:%@",strUrl);
                [readview stop];
                [weakSelf accordingQcode:strUrl];
                //播放扫描二维码的声音
//                SystemSoundID soundID;
//                NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"noticeMusic" ofType:@"wav"];
//                AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
//                AudioServicesPlaySystemSound(soundID);
            }else{
                NSLog(@"识别失败");
//                [self performSelector:@selector(reStartScan) withObject:nil afterDelay:1.5f];
                
            }
        }];
    }
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

#pragma mark - 扫描结果处理
- (void)accordingQcode:(NSString *)str
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"扫描结果" message:str preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [readview start];
    }];
    UIAlertAction *alertAction2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (str != nil) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(scanCardReturn:)]) {
                [self.delegate scanCardReturn:str];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [readview start];
        }
        
    }];
    [alertController addAction:alertAction1];
    [alertController addAction:alertAction2];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)reStartScan
{
    readview.is_Anmotion = NO;
    
    if (readview.is_AnmotionFinished) {
        [readview loopDrawLine];
    }
    
    [readview start];
}

#pragma mark - view
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (isFirst || isPush) {
        if (readview) {
//            [self reStartScan];
        }
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (readview) {
        [readview stop];
        readview.is_Anmotion = YES;
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (isFirst) {
        isFirst = NO;
    }
    if (isPush) {
        isPush = NO;
    }
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
