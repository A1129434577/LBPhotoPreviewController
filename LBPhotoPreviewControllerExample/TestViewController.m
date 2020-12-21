//
//  ViewController.m
//  LBPhotoPreviewControllerExample
//
//  Created by 刘彬 on 2020/8/31.
//  Copyright © 2020 刘彬. All rights reserved.
//

#import "TestViewController.h"
#import "LBPhotoPreviewController.h"
#import "UIButton+WebCache.h"

@interface TestViewController ()
@property (nonatomic, strong) NSMutableArray<UIButton *> *btnArray;
@end

@implementation TestViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        _btnArray = [NSMutableArray array];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"点击开始浏览";
    
    NSArray<NSString *> *imageNameArray = @[@"1.jpg",
                                            @"2.png",
                                            @"https://image-static.segmentfault.com/419/538/4195380633-58e8f762b0d73_articlex",
                                            @"3.jpg"];
    
    
    [imageNameArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame)-300)/2, 100+idx*(25+200), 300, 200)];
        btn.clipsToBounds = YES;
        btn.layer.cornerRadius = 20;
        btn.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [btn addTarget:self action:@selector(phonePreviewTest:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        
        
        UIImage *image = [UIImage imageNamed:obj];
        if (image) {
            [btn setImage:image forState:UIControlStateNormal];
        }else{
            [btn sd_setImageWithURL:[NSURL URLWithString:obj] forState:UIControlStateNormal];
        }
        [self.btnArray addObject:btn];
    }];
    
    
}

-(void)phonePreviewTest:(UIButton *)sender{
    LBImageObject *imag1 = [LBImageObject objectWithImage:[UIImage imageNamed:@"1.jpg"]];
    LBImageObject *imag2 = [LBImageObject objectWithImage:[UIImage imageNamed:@"2.png"]];
    LBImageObject *urlImag = [LBImageObject objectWithImageUrl:[NSURL URLWithString:@"https://image-static.segmentfault.com/419/538/4195380633-58e8f762b0d73_articlex"]];
    LBImageObject *imag3 = [LBImageObject objectWithImage:[UIImage imageNamed:@"3.jpg"]];
    
    LBPhotoPreviewController *photoPreviewC = [[LBPhotoPreviewController alloc] initWithSourceViews:self.btnArray];
    photoPreviewC.imageObjectArray = @[imag1,imag2,urlImag,imag3];
    photoPreviewC.previewScrollView.currentPage = [self.btnArray indexOfObject:sender];
    [self presentViewController:photoPreviewC animated:YES completion:nil];
}
@end
