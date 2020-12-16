//
//  HTTPViewController.h
//  test
//
//  Created by 刘彬 on 2019/8/6.
//  Copyright © 2019 刘彬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBReusableScrollView.h"

NS_ASSUME_NONNULL_BEGIN
@protocol LBImageProtocol <NSObject>
@property (nonatomic,strong)UIImage *image;
@property (nonatomic,strong)NSURL *imageUrl;
@end

@interface LBImageObject : NSObject<LBImageProtocol>
@property (nonatomic,strong)UIImage *image;
@property (nonatomic,strong)NSURL *imageUrl;
+ (instancetype)objectWithImage:(UIImage *)image;
+ (instancetype)objectWithImageUrl:(NSURL *)url;
@end

typedef NS_ENUM(NSUInteger, LBPhotoPreviewrRightButtonStyle) {
    LBPhotoPreviewrRightDeleteButtonStyle = 0,
    LBPhotoPreviewrRightMoreButtonStyle,
};

@interface LBPhotoPreviewController : UIViewController
@property (nonatomic,strong,readonly)LBReusableScrollView *previewScrollView;
@property (nonatomic,strong)NSArray<NSObject<LBImageProtocol> *> * imageObjectArray;

@property (nonatomic,strong,readonly)UIButton *rightButton;//默认删除按钮样式和点击删除功能，可以自定义
@property (nonatomic, assign) LBPhotoPreviewrRightButtonStyle rightButtonStyle;
@property (nonatomic, copy) void(^rightButtonDeletedHandler)(NSObject<LBImageProtocol> *imageObject);//如果使用自定义action，此block将无效
@property (nonatomic, copy) void(^rightButtonSavePhotoHandler)(NSObject<LBImageProtocol> *imageObject,BOOL success, NSError *_Nullable error);//如果使用自定义action，此block将无效
@property (nonatomic, copy) void(^rightButtonCopyImageHandler)(NSObject<LBImageProtocol> *imageObject,BOOL success, NSError *_Nullable error);//如果使用自定义action，此block将无效

/// 初始化
/// @param sourceViews 可以通过设置sourceViews改变其推出动画，如果sourceViews不为空，推出动画将从sourceViews的currentPage开始，如果sourceViews为空，则为系统默认推出动画
-(instancetype)initWithSourceViews:(nullable NSArray<UIView *> *)sourceViews;
@end

NS_ASSUME_NONNULL_END
