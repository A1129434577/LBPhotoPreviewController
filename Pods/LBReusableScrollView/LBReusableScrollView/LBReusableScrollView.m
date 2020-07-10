//
//  LBReusableScrollView.m
//  test
//
//  Created by 刘彬 on 2019/9/5.
//  Copyright © 2019 刘彬. All rights reserved.
//

#import "LBReusableScrollView.h"

@interface LBReusableScrollView()<UIScrollViewDelegate>
@property (nonatomic,strong)NSMutableArray<UIView *> *pageViews;
@end

@implementation LBReusableScrollView

- (instancetype)init
{
    return [[self.class alloc] initWithFrame:CGRectZero];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _pageViews = [NSMutableArray array];
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return self;
}
-(void)setLb_delegate:(id<LBReusableScrollViewDelegate>)lb_delegate{
    _lb_delegate = lb_delegate;
    self.delegate = self;
    [self reloadData];
}
-(void)setDelegate:(id<UIScrollViewDelegate>)delegate{
    if (delegate) [super setDelegate:self];
}

-(void)setCurrentPage:(NSUInteger)currentPage{
    _currentPage = currentPage;
    
    [self reloadData];
    
    BOOL isHorizontal = (self.rollingDirection == LBRollingHorizontal);
    [self setContentOffset:CGPointMake(currentPage*(isHorizontal?CGRectGetWidth(self.bounds):0), currentPage*(isHorizontal?0:CGRectGetHeight(self.bounds))) animated:NO];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //只显示当前的三页
    BOOL isHorizontal = (self.rollingDirection == LBRollingHorizontal);

    NSUInteger currentPage = 0;
    if (isHorizontal){
        currentPage = scrollView.contentOffset.x/CGRectGetWidth(scrollView.bounds);
        if (currentPage < _currentPage) {//当是向前滚动的时候要滚到前一页的一半才重新刷新页面
            if (scrollView.contentOffset.x-CGRectGetWidth(scrollView.bounds)*currentPage > CGRectGetWidth(scrollView.bounds)/2) {
                currentPage = _currentPage;
            }
        }
    }else{
        currentPage = scrollView.contentOffset.y/CGRectGetHeight(scrollView.bounds);
        if (currentPage < _currentPage) {//当是向前滚动的时候要滚到前一页的一半才重新刷新页面
            if (scrollView.contentOffset.y-CGRectGetHeight(scrollView.bounds)*currentPage > CGRectGetHeight(scrollView.bounds)/2) {
                currentPage = _currentPage;
            }
        }
    }
    
    
    if (_currentPage != currentPage) {
        _currentPage = currentPage;
        
        [self loadCurrentPagesContent];
    }
    
    if ([self.lb_delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.lb_delegate scrollViewDidScroll:scrollView];
    }
}

/**
 加载当前的三个页面
 */
-(void)loadCurrentPagesContent{
    [_pageViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];


    BOOL isHorizontal = (self.rollingDirection == LBRollingHorizontal);


    NSUInteger pagesNumber = [self.lb_delegate numberOfPagesInScrollView:self];
    NSInteger lastPage = _currentPage-1;
    NSInteger nextPage = _currentPage+1;

    if (lastPage>=0 && lastPage<pagesNumber) {
        UIView *lastPageView = [self.lb_delegate scrollView:self viewForPage:lastPage];
        lastPageView.frame = CGRectMake(isHorizontal?lastPage*CGRectGetWidth(self.bounds):0, isHorizontal?0:lastPage*CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        [self addSubview:lastPageView];
        [_pageViews addObject:lastPageView];
    }

    if (_currentPage>=0 && _currentPage<pagesNumber) {
        UIView *currentPageView = [self.lb_delegate scrollView:self viewForPage:_currentPage];
        currentPageView.frame = CGRectMake(isHorizontal?(_currentPage)*CGRectGetWidth(self.bounds):0, isHorizontal?0:(_currentPage)*CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        [self addSubview:currentPageView];
        [_pageViews addObject:currentPageView];
    }

    if (nextPage>=0 && nextPage<pagesNumber) {
        UIView *nextPageView = [self.lb_delegate scrollView:self viewForPage:nextPage];
        nextPageView.frame = CGRectMake(isHorizontal?nextPage*CGRectGetWidth(self.bounds):0, isHorizontal?0:nextPage*CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        [self addSubview:nextPageView];
        [_pageViews addObject:nextPageView];
    }
}

-(void)reloadData{
    if (self.rollingDirection == LBRollingHorizontal) {
        self.contentSize = CGSizeMake(CGRectGetWidth(self.bounds)*[self.lb_delegate numberOfPagesInScrollView:self], CGRectGetHeight(self.bounds));
    }else{
        self.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)*[self.lb_delegate numberOfPagesInScrollView:self]);
    }
    [self loadCurrentPagesContent];
}

//如果本类没实现的代理方法由lb_delegate实现
- (BOOL)respondsToSelector:(SEL)aSelector{
    BOOL respondsSelector = [super respondsToSelector:aSelector];
    if (!respondsSelector && [self.lb_delegate respondsToSelector:aSelector]) {
        return YES;
    }
    return respondsSelector;
}
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if (![super respondsToSelector:aSelector] && [self.lb_delegate respondsToSelector:aSelector]) {
        return self.lb_delegate;
    }
    return [super forwardingTargetForSelector: aSelector];
}
@end
