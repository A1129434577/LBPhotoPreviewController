//
//  HTTPViewController.m
//  test
//
//  Created by 刘彬 on 2019/8/6.
//  Copyright © 2019 刘彬. All rights reserved.
//

#import "LBPhotoPreviewController.h"
#import "UIImageView+WebCache.h"

@implementation LBImageObject
+ (instancetype)objectWithImage:(UIImage *)image{
    LBImageObject *object = [[self alloc] init];
    object.image = image;
    return object;
}
+ (instancetype)objectWithImageUrl:(NSURL *)url{
    LBImageObject *object = [[self alloc] init];
    object.imageUrl = url;
    return object;
}
@end

@interface LBPhotoPreviewController ()<LBReusableScrollViewDelegate>
@property (nonatomic,assign)BOOL navigationBarIsHidden;
@property (nonatomic, strong)NSMutableArray<NSObject<LBImageProtocol> *> * privateImageObjects;

@property (nonatomic, strong) UIView  *navigationBarView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation LBPhotoPreviewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:NSStringFromSelector(@selector(privateImageObjects)) options:NSKeyValueObservingOptionNew context:nil];
        
        LBReusableScrollView *previewScrollView = [[LBReusableScrollView alloc] init];
        previewScrollView.showsVerticalScrollIndicator = NO;
        previewScrollView.showsHorizontalScrollIndicator = NO;
        // 单击
        UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCallback:)];
        [previewScrollView addGestureRecognizer:singleTap];
        
        previewScrollView.backgroundColor = [UIColor clearColor];
        previewScrollView.pagingEnabled = YES;
        previewScrollView.lb_delegate = self;
        _previewScrollView = previewScrollView;
        
    }
    return self;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationBarIsHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    _titleLabel.text = [NSString stringWithFormat:@"%ld/%ld",self.privateImageObjects.count?_previewScrollView.currentPage + 1:0,self.privateImageObjects.count];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:self.navigationBarIsHidden animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    CGFloat safeAreaInsetsTop = 20;
    if (@available(iOS 11.0, *)) {
        safeAreaInsetsTop = [[[UIApplication sharedApplication] delegate] window].safeAreaInsets.top;
        if(self.navigationController && !self.navigationController.navigationBar.hidden){
            safeAreaInsetsTop += CGRectGetHeight(self.navigationController.navigationBar.frame);
        }
    }else if(self.navigationController && !self.navigationController.navigationBar.hidden){
        safeAreaInsetsTop = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    }
    
    CGFloat safeAreaInsetsBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeAreaInsetsBottom = [[[UIApplication sharedApplication] delegate] window].safeAreaInsets.bottom;
        if(self.tabBarController && !self.tabBarController.tabBar.hidden && !self.hidesBottomBarWhenPushed){
            safeAreaInsetsBottom  = CGRectGetHeight(self.tabBarController.tabBar.frame);
        }
    }else if(self.tabBarController && !self.tabBarController.tabBar.hidden && !self.hidesBottomBarWhenPushed){
        safeAreaInsetsBottom = CGRectGetHeight(self.tabBarController.tabBar.frame);
    }

//    self.previewScrollView.frame = CGRectMake(0, safeAreaInsetsTop, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-safeAreaInsetsTop-safeAreaInsetsBottom);
    self.previewScrollView.frame = self.view.bounds;
    [self.view addSubview:_previewScrollView];
    
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44+safeAreaInsetsTop)];
    titleView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self.view addSubview:titleView];
    _navigationBarView = titleView;
    
    // 返回按钮
    UIImage * image = [UIImage imageNamed:@"lbphoto_back"];
    UIButton * backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, safeAreaInsetsTop, 44, 44)];
    [backBtn setImage:image forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:backBtn];
    
    
    // 顺序Label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(_navigationBarView.frame)-200)/2, CGRectGetMinY(backBtn.frame), 200, CGRectGetHeight(backBtn.bounds))];
    titleLabel.font = [UIFont boldSystemFontOfSize:19.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [titleView addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    // 删除按钮
    image = [UIImage imageNamed:@"lbphoto_delete"];
    UIButton * deleteBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(_navigationBarView.frame)-CGRectGetHeight(backBtn.frame), CGRectGetMinY(backBtn.frame), CGRectGetHeight(backBtn.frame), CGRectGetHeight(backBtn.frame))];
    [deleteBtn setImage:image forState:UIControlStateNormal];
    [deleteBtn setImageEdgeInsets:UIEdgeInsetsMake((CGRectGetHeight([UINavigationBar appearance].bounds)-image.size.height)/2, 0, (CGRectGetHeight([UINavigationBar appearance].bounds)-image.size.height)/2, 0)];
    [deleteBtn addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:deleteBtn];
    _deleteBtn = deleteBtn;
}
-(void)setImageObjectArray:(NSArray<NSObject<LBImageProtocol> *> *)imageObjectArray{
    _imageObjectArray = imageObjectArray;
    self.privateImageObjects = [NSMutableArray arrayWithArray:imageObjectArray];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(privateImageObjects))]) {
        [_previewScrollView reloadData];
    }
}


#pragma mark LBReusableScrollViewDelegate
-(NSInteger)numberOfPagesInScrollView:(LBReusableScrollView *)scrollView{
    return self.privateImageObjects.count;
}
-(UIView *)scrollView:(LBReusableScrollView *)scrollView viewForPage:(NSUInteger)page{
    NSObject<LBImageProtocol> *image = [self.privateImageObjects objectAtIndex:page];
    // 用于图片的捏合缩放
    UIScrollView *pinchScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(scrollView.bounds)*page, 0, CGRectGetWidth(scrollView.bounds), CGRectGetHeight(scrollView.bounds))];
    pinchScrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollView.bounds), CGRectGetHeight(scrollView.bounds));
    pinchScrollView.minimumZoomScale = 1.0;
    pinchScrollView.delegate = self;
    pinchScrollView.showsHorizontalScrollIndicator = NO;
    pinchScrollView.showsVerticalScrollIndicator = NO;
    pinchScrollView.backgroundColor = [UIColor clearColor];
    // 双击
    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureCallback:)];
    doubleTap.numberOfTapsRequired = 2;
    [pinchScrollView addGestureRecognizer:doubleTap];
    [scrollView.gestureRecognizers enumerateObjectsUsingBlock:^(__kindof UIGestureRecognizer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:UITapGestureRecognizer.self]) {
            [obj requireGestureRecognizerToFail:doubleTap];
        }
    }];
    
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:pinchScrollView.bounds];
    if (image.image) {
        imageView.image = image.image;
    }else if (image.imageUrl){
        [imageView sd_setImageWithURL:image.imageUrl];        
    }
    imageView.clipsToBounds  = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.contentScaleFactor = [[UIScreen mainScreen] scale];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.tag = 1000;
    [pinchScrollView addSubview:imageView];
    
    CGSize imgSize = [imageView.image size];
    CGFloat scaleX = CGRectGetWidth(self.view.bounds)/imgSize.width;
    CGFloat scaleY = CGRectGetHeight(self.view.bounds)/imgSize.height;
    if (scaleX > scaleY) {
        CGFloat imgViewWidth = imgSize.width * scaleY;
        pinchScrollView.maximumZoomScale = CGRectGetWidth(self.view.bounds)/imgViewWidth;
    } else {
        CGFloat imgViewHeight = imgSize.height * scaleX;
        pinchScrollView.maximumZoomScale = CGRectGetHeight(self.view.bounds)/imgViewHeight;
    }
    
    return pinchScrollView;
}
#pragma mark LBReusableScrollViewDelegate UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView viewWithTag:1000];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _titleLabel.text = [NSString stringWithFormat:@"%ld/%ld",self.privateImageObjects.count?_previewScrollView.currentPage + 1:0,self.privateImageObjects.count];
}

#pragma mark - ButtonAction处理

- (void)backAction
{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)deleteAction
{
    if (_previewScrollView.currentPage >= self.privateImageObjects.count) {
        return;
    }
    // 移除视图
    NSObject<LBImageProtocol> *image = [self.privateImageObjects objectAtIndex:_previewScrollView.currentPage];
    // block
    self.assetDeleteHandler?self.assetDeleteHandler(image):NULL;
    
    [[self mutableArrayValueForKey:NSStringFromSelector(@selector(privateImageObjects))] removeObject:image];
    if (_previewScrollView.currentPage-1>=0 && _previewScrollView.currentPage-1<_privateImageObjects.count) {
        _previewScrollView.currentPage = _previewScrollView.currentPage-1;
    }
    // 更新索引
    _titleLabel.text = [NSString stringWithFormat:@"%ld/%ld",self.privateImageObjects.count?_previewScrollView.currentPage + 1:0,self.privateImageObjects.count];

    // 返回
    if (![self.privateImageObjects count]) {
        [self backAction];
    }
}

#pragma mark - 手势处理
- (void)singleTapGestureCallback:(UITapGestureRecognizer *)gesture
{
    [UIView animateWithDuration:0.2 animations:^{
        if (CGRectGetMinY(self.navigationBarView.frame) == 0) {
            self.navigationBarView.frame = CGRectMake(CGRectGetMinX(self.navigationBarView.frame), -CGRectGetHeight(self.navigationBarView.frame), CGRectGetWidth(self.navigationBarView.frame), CGRectGetHeight(self.navigationBarView.frame));
        }else{
            self.navigationBarView.frame = CGRectMake(CGRectGetMinX(self.navigationBarView.frame), 0, CGRectGetWidth(self.navigationBarView.frame), CGRectGetHeight(self.navigationBarView.frame));
        }
    }];
}

- (void)doubleTapGestureCallback:(UITapGestureRecognizer *)gesture
{
    UIScrollView *pinchScrollView = (UIScrollView *)gesture.view;
    CGFloat zoomScale = pinchScrollView.zoomScale;
    if (zoomScale == pinchScrollView.maximumZoomScale) {
        zoomScale = 0;
    } else {
        zoomScale = pinchScrollView.maximumZoomScale;
    }
    [UIView animateWithDuration:0.35 animations:^{
        pinchScrollView.zoomScale = zoomScale;
    }];
}

-(void)dealloc{
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(privateImageObjects))];
}
@end
