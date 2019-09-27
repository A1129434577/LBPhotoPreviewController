//
//  LBReusableScrollView.h
//  test
//
//  Created by 刘彬 on 2019/9/5.
//  Copyright © 2019 刘彬. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LBReusableScrollView;
@protocol LBReusableScrollViewDelegate <UIScrollViewDelegate>
@required
- (NSInteger)numberOfPagesInScrollView:(LBReusableScrollView *)scrollView;
- (UIView *)scrollView:(LBReusableScrollView *)scrollView viewForPage:(NSUInteger)page;
@end

typedef NS_ENUM(NSUInteger, LBRollingDirection) {
    LBRollingHorizontal = 0,
    LBRollingVertical,
};

@interface LBReusableScrollView : UIScrollView
@property (nonatomic,assign)LBRollingDirection rollingDirection;
@property (nonatomic,strong)id<LBReusableScrollViewDelegate> lb_delegate;
@property (nonatomic,assign)NSUInteger currentPage;//page从0开始

-(void)reloadData;
@end


NS_ASSUME_NONNULL_END
