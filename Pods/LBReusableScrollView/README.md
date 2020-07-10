# LBReusableScrollView
```objc
LBReusableScrollView *reusableScrollView = [[LBReusableScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 400)];
reusableScrollView.pagingEnabled = YES;
reusableScrollView.lb_delegate = self;


#pragma mark LBReusableScrollViewDelegate
-(NSInteger)numberOfPagesInScrollView:(LBReusableScrollView *)scrollView{
    return 1000;
}

-(UIView *)scrollView:(LBReusableScrollView *)scrollView viewForPage:(NSUInteger)page{
    UIView *v = [[UIView alloc] initWithFrame:scrollView.bounds];
    if (page%2 == 0) {
        v.backgroundColor = [UIColor cyanColor];
    }else{
        v.backgroundColor = [UIColor magentaColor];
    }
    return v;
}
```
