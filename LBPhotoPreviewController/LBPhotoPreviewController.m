//
//  HTTPViewController.m
//  test
//
//  Created by 刘彬 on 2019/8/6.
//  Copyright © 2019 刘彬. All rights reserved.
//

#import "LBPhotoPreviewController.h"
#import "UIImageView+WebCache.h"
#import <Photos/Photos.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#define LB_KEY_WINDOW \
({\
id<UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;\
UIWindow *keyWindow = [delegate respondsToSelector:@selector(window)]?delegate.window:nil;\
if (keyWindow == nil) {\
if (@available(ios 13, *)) {\
for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes){\
if (windowScene.activationState == UISceneActivationStateForegroundActive){\
UIWindow *window = windowScene.windows.firstObject;\
if (window) {\
keyWindow = window;\
}\
break;\
}\
}\
if (keyWindow == nil) {\
keyWindow = [UIApplication sharedApplication].keyWindow;\
}\
}else{\
keyWindow = [UIApplication sharedApplication].keyWindow;\
}\
}\
keyWindow;\
})

#define LB_SAFE_AREA_TOP_HEIGHT(ViewController) \
({\
CGFloat safeAreaInsetsTop = 0;\
if (@available(ios 13, *)) {\
safeAreaInsetsTop = CGRectGetMaxY(LB_KEY_WINDOW.windowScene.statusBarManager.statusBarFrame);\
}else{\
safeAreaInsetsTop = CGRectGetMaxY([UIApplication sharedApplication].statusBarFrame);\
}\
if(ViewController.navigationController && !ViewController.navigationController.navigationBar.hidden && !ViewController.navigationController.navigationBarHidden){\
safeAreaInsetsTop += CGRectGetHeight(ViewController.navigationController.navigationBar.frame);\
}\
safeAreaInsetsTop;\
})

#define LB_SAFE_AREA_BOTTOM_HEIGHT(ViewController) \
({\
CGFloat safeAreaInsetsBottom = 0;\
if (@available(iOS 11.0, *)) {\
safeAreaInsetsBottom = LB_KEY_WINDOW.safeAreaInsets.bottom;\
}\
if(ViewController.tabBarController && !ViewController.tabBarController.tabBar.hidden && !ViewController.hidesBottomBarWhenPushed){\
safeAreaInsetsBottom  += CGRectGetHeight(ViewController.tabBarController.tabBar.frame);\
}\
safeAreaInsetsBottom;\
})

#define LB_SAFE_AREA_VERTICAL_HEIGHT(ViewController) \
({\
LB_SAFE_AREA_TOP_HEIGHT(ViewController) + LB_SAFE_AREA_BOTTOM_HEIGHT(ViewController);\
})


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

typedef enum {
    LBPhotoPreviewAnimationTypePresent,
    LBPhotoPreviewAnimationTypeDismiss,
} LBPhotoPreviewTransitionsAnimationType;
@interface LBPhotoPreviewTransitioning : NSObject<UIViewControllerTransitioningDelegate,UIViewControllerAnimatedTransitioning>
@property (nonatomic,assign)LBPhotoPreviewTransitionsAnimationType type;
@end
#define VIEW_TAG 666666
#define LBPhotoPreviewImageViewTag VIEW_TAG-1
@interface LBPhotoPreviewController ()<LBReusableScrollViewDelegate>
@property (nonatomic,weak)UIView *sourceView;
@property (nonatomic,strong)LBPhotoPreviewTransitioning *transitioning;

@property (nonatomic,assign)BOOL navigationBarIsHidden;
@property (nonatomic, strong)NSMutableArray<NSObject<LBImageProtocol> *> * privateImageObjects;

@property (nonatomic, strong) UIView  *titleView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic , assign)CGPoint startPoint;
@property (nonatomic , assign)CGFloat zoomScale;
@property (nonatomic , assign)CGPoint startCenter;

@end

@implementation LBPhotoPreviewController
- (instancetype)init
{
    return [self initWithSourceView:nil];
}
- (instancetype)initWithSourceView:(UIView *)sourceView
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        
        if (sourceView) {
            self.sourceView = sourceView;
            _transitioning = [[LBPhotoPreviewTransitioning alloc] init];
            self.transitioningDelegate = _transitioning;
        }
        
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
        _previewScrollView = previewScrollView;;
        
        
        UIButton *rightButton = [[UIButton alloc] init];
        _rightButton = rightButton;
        self.rightButtonStyle = LBPhotoPreviewrRightMoreButtonStyle;
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
    if (@available(*, iOS 11.0)) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor blackColor];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self.view addGestureRecognizer:panGesture];
    
    self.previewScrollView.frame = self.view.bounds;
    [self.view addSubview:_previewScrollView];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44+LB_SAFE_AREA_TOP_HEIGHT(self))];
    titleView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    [self.view addSubview:titleView];
    _titleView = titleView;
    
    NSBundle *bundle = [self LBPhotoPreviewControllerBundle];
    // 返回按钮
    UIImage * image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"lbphoto_back@2x" ofType:@"png"]];
    UIButton * backBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, LB_SAFE_AREA_TOP_HEIGHT(self), 44, 44)];
    [backBtn setImage:image forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:backBtn];
    
    // 顺序Label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(_titleView.frame)-200)/2, CGRectGetMinY(backBtn.frame), 200, CGRectGetHeight(backBtn.bounds))];
    titleLabel.font = [UIFont boldSystemFontOfSize:19.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    [titleView addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    
    // 右边按钮
    self.rightButton.frame = CGRectMake(CGRectGetWidth(_titleView.frame)-CGRectGetHeight(backBtn.frame), CGRectGetMinY(backBtn.frame), CGRectGetHeight(backBtn.frame), CGRectGetHeight(backBtn.frame));
    [self.rightButton setImageEdgeInsets:UIEdgeInsetsMake((CGRectGetHeight(self.rightButton.bounds)-image.size.height)/2, 0, (CGRectGetHeight(self.rightButton.bounds)-image.size.height)/2, 0)];
    [titleView addSubview:self.rightButton];
}
#pragma mark setter
-(void)setImageObjectArray:(NSArray<NSObject<LBImageProtocol> *> *)imageObjectArray{
    _imageObjectArray = imageObjectArray;
    self.privateImageObjects = [NSMutableArray arrayWithArray:imageObjectArray];
}
-(void)setRightButtonStyle:(LBPhotoPreviewrRightButtonStyle)rightButtonStyle{
    _rightButtonStyle = rightButtonStyle;
    
    NSBundle *bundle = [self LBPhotoPreviewControllerBundle];
    switch (rightButtonStyle) {
        case LBPhotoPreviewrRightDeleteButtonStyle:
        {
            UIImage *image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"lbphoto_delete@2x" ofType:@"png"]];
            [self.rightButton setImage:image forState:UIControlStateNormal];
            [self.rightButton addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case LBPhotoPreviewrRightMoreButtonStyle:
        {
            UIImage *image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"lbphoto_more@2x" ofType:@"png"]];
            [self.rightButton setImage:image forState:UIControlStateNormal];
            [self.rightButton addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark KVO
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
    UIScrollView *pinchScrollView;
    @autoreleasepool {
        NSObject<LBImageProtocol> *image = [self.privateImageObjects objectAtIndex:page];
        // 用于图片的捏合缩放
        pinchScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(CGRectGetWidth(scrollView.bounds)*page, 0, CGRectGetWidth(scrollView.bounds), CGRectGetHeight(scrollView.bounds))];
        pinchScrollView.tag = VIEW_TAG+page;
        pinchScrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollView.bounds), CGRectGetHeight(scrollView.bounds));
        pinchScrollView.minimumZoomScale = 1.0;
        pinchScrollView.delegate = self;
        pinchScrollView.showsHorizontalScrollIndicator = NO;
        pinchScrollView.showsVerticalScrollIndicator = NO;
        pinchScrollView.backgroundColor = [UIColor clearColor];
        // 双击
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureCallback:)];
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
        imageView.tag = LBPhotoPreviewImageViewTag;
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
    }
    
    return pinchScrollView;
}
#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView viewWithTag:LBPhotoPreviewImageViewTag];
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
    self.rightButtonDeletedHandler?self.rightButtonDeletedHandler(image):NULL;
    
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

-(void)moreAction{
    NSObject<LBImageProtocol> *imageObj = [self.privateImageObjects objectAtIndex:_previewScrollView.currentPage];
    UIScrollView *pinchScrollView = (UIScrollView *)[self.previewScrollView viewWithTag:VIEW_TAG+self.previewScrollView.currentPage];
    UIImageView *imageView = [pinchScrollView viewWithTag:LBPhotoPreviewImageViewTag];
    
    
    __weak typeof(self) weakSelf = self;
    UIAlertController *moreActionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [moreActionSheet addAction:[UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImage *image = imageView.image;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:UIImagePNGRepresentation(image) options:nil];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                imageObj.image = image;
            }
            if (weakSelf.rightButtonMoreHandler) {
                weakSelf.rightButtonMoreHandler(imageObj, success, NO, error);
            }
        }];
    }]];
    [moreActionSheet addAction:[UIAlertAction actionWithTitle:@"拷贝图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImage *image = imageView.image;
        if (image) {
            UIPasteboard *pastboard = [UIPasteboard generalPasteboard];
            pastboard.image = image;
            imageObj.image = image;
            if (weakSelf.rightButtonMoreHandler) {
                weakSelf.rightButtonMoreHandler(imageObj, NO, YES, nil);
            }
        }else{
            NSError *error = [NSError errorWithDomain:@"LBPhotoPreviewControllerError" code:5000 userInfo:@{NSLocalizedDescriptionKey:@"拷贝图片失败！"}];
            if (weakSelf.rightButtonMoreHandler) {
                weakSelf.rightButtonMoreHandler(imageObj, NO, NO, error);
            }
        }
        
    }]];
    [moreActionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL]];
    [self presentViewController:moreActionSheet animated:YES completion:nil];
    
}

#pragma mark - 手势处理
- (void)singleTapGestureCallback:(UITapGestureRecognizer *)gesture
{
    [UIView animateWithDuration:0.2 animations:^{
        if (CGRectGetMinY(self.titleView.frame) == 0) {
            self.titleView.frame = CGRectMake(CGRectGetMinX(self.titleView.frame), -CGRectGetHeight(self.titleView.frame), CGRectGetWidth(self.titleView.frame), CGRectGetHeight(self.titleView.frame));
        }else{
            self.titleView.frame = CGRectMake(CGRectGetMinX(self.titleView.frame), 0, CGRectGetWidth(self.titleView.frame), CGRectGetHeight(self.titleView.frame));
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

- (void)panGestureAction:(UIPanGestureRecognizer *)pan {
    UIScrollView *pinchScrollView = (UIScrollView *)[self.previewScrollView viewWithTag:VIEW_TAG+self.previewScrollView.currentPage];
    UIImageView *imageView = [pinchScrollView viewWithTag:LBPhotoPreviewImageViewTag];
    CGPoint location = [pan locationInView:self.view];
    CGPoint point = [pan translationInView:self.view];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            _startPoint = location;
            _zoomScale = pinchScrollView.zoomScale;
            if (_zoomScale == 0) {
                _zoomScale = 1;
            }
            _startCenter = imageView.center;
            self.titleView.hidden = NO;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            if (location.y - _startPoint.y < 0) {
                return;
            }
            double percent = 1 - fabs(point.y) / CGRectGetHeight(self.previewScrollView.frame);// 移动距离 / 整个屏幕
            double scalePercent = MAX(percent, 0.3);
            if (location.y - _startPoint.y < 0) {
                scalePercent = 1.0 * _zoomScale;
            }else {
                scalePercent = _zoomScale * scalePercent;
            }
            CGAffineTransform scale = CGAffineTransformMakeScale(scalePercent, scalePercent);
            imageView.transform = scale;
            imageView.center = CGPointMake(self.startCenter.x + point.x, self.startCenter.y + point.y);
            self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scalePercent/_zoomScale];
            self.view.superview.backgroundColor = [UIColor clearColor];
            self.titleView.hidden = YES;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (point.y > 100 ) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }else {
                CGAffineTransform scale = CGAffineTransformMakeScale(_zoomScale , _zoomScale);
                [UIView animateWithDuration:0.25 animations:^{
                    imageView.transform = scale;
                    self.view.backgroundColor = [UIColor blackColor];
                    self.view.superview.backgroundColor = [UIColor blackColor];
                    imageView.center = self.startCenter;
                }completion:^(BOOL finished) {
                    [pinchScrollView layoutSubviews];
                    self.titleView.hidden = NO;
                }];
            }
        }
            break;
            
        default:
            break;
    }
}

- (NSBundle *)LBPhotoPreviewControllerBundle
{
    static NSBundle *progressHUDBundle = nil;
    if (progressHUDBundle == nil) {
        progressHUDBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"LBPhotoPreviewController" ofType:@"bundle"]];
    }
    return progressHUDBundle;
}

-(void)dealloc{
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(privateImageObjects))];
}
@end



@implementation LBPhotoPreviewTransitioning

#pragma mark - UIViewControllerAnimatedTransitioning
-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    
    if (self.type == LBPhotoPreviewAnimationTypePresent) {
        //目标控制器
        LBPhotoPreviewController *toViewController = (LBPhotoPreviewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        [containerView addSubview:toViewController.view];
        
        CGRect sourceViewFrameInWindow = [LB_KEY_WINDOW convertRect:toViewController.sourceView.frame fromView:toViewController.sourceView.superview];
        
        toViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGRectGetWidth(sourceViewFrameInWindow)/CGRectGetWidth(toViewController.view.frame), CGRectGetHeight(sourceViewFrameInWindow)/CGRectGetHeight(toViewController.view.frame));
        toViewController.view.center = CGPointMake(CGRectGetMidX(sourceViewFrameInWindow), CGRectGetMidY(sourceViewFrameInWindow));
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toViewController.view.transform = CGAffineTransformIdentity;
            toViewController.view.center = LB_KEY_WINDOW.center;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }else if (self.type == LBPhotoPreviewAnimationTypeDismiss){
        containerView.backgroundColor = [UIColor clearColor];
        
        //源控制器
        LBPhotoPreviewController *fromViewController = (LBPhotoPreviewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        fromViewController.titleView.hidden = YES;
        fromViewController.view.backgroundColor = [UIColor clearColor];
        
        CGRect sourceViewFrameInWindow = [LB_KEY_WINDOW convertRect:fromViewController.sourceView.frame fromView:fromViewController.sourceView.superview];
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            
            fromViewController.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.01, 0.01);
            fromViewController.view.center = CGPointMake(CGRectGetMidX(sourceViewFrameInWindow), CGRectGetMidY(sourceViewFrameInWindow));
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

#pragma mark - UIViewControllerTransitioningDelegate
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.type = LBPhotoPreviewAnimationTypePresent;
    return self;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.type = LBPhotoPreviewAnimationTypeDismiss;
    return self;
}

@end
#pragma clang diagnostic pop
