//
//  ViewController.m
//  LBPhotoPreviewControllerExample
//
//  Created by 刘彬 on 2020/8/31.
//  Copyright © 2020 刘彬. All rights reserved.
//

#import "TestViewController.h"
#import "LBPhotoPreviewController.h"


@interface TestViewController ()
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame)-300)/2, 150, 300, 400)];
    btn.backgroundColor = [UIColor lightGrayColor];
    btn.layer.cornerRadius = 10;
    [btn setTitle:@"本地和网络图片流量" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(phonePreviewTest:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

-(void)phonePreviewTest:(UIButton *)sender{
    LBImageObject *imag1 = [LBImageObject objectWithImage:[UIImage imageNamed:@"1.jpg"]];
    LBImageObject *imag2 = [LBImageObject objectWithImage:[UIImage imageNamed:@"2.png"]];
    LBImageObject *urlImag = [LBImageObject objectWithImageUrl:[NSURL URLWithString:@"https://image-static.segmentfault.com/419/538/4195380633-58e8f762b0d73_articlex"]];
    LBImageObject *imag3 = [LBImageObject objectWithImage:[UIImage imageNamed:@"3.jpg"]];
    
    LBPhotoPreviewController *photoPreviewC = [[LBPhotoPreviewController alloc] initWithSourceViews:@[sender]];
    photoPreviewC.imageObjectArray = @[imag1,imag2,urlImag,imag3];
    photoPreviewC.previewScrollView.currentPage = 1;
    [self presentViewController:photoPreviewC animated:YES completion:nil];
}
@end
