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

@interface LBPhotoPreviewController : UIViewController
@property (nonatomic,strong,readonly)LBReusableScrollView *previewScrollView;
@property (nonatomic,strong,readonly)UIButton *deleteBtn;
@property (nonatomic,strong)NSArray<NSObject<LBImageProtocol> *> * imageObjectArray;
@property (nonatomic, copy) void(^assetDeleteHandler)(NSObject<LBImageProtocol> *imageObject);
@end

NS_ASSUME_NONNULL_END
