# LBPhotoPreviewController
```objc
//同时支持本地图片和网络图片
LBImageObject *imag1 = [LBImageObject objectWithImage:[UIImage imageNamed:@"1.jpg"]];
LBImageObject *imag2 = [LBImageObject objectWithImage:[UIImage imageNamed:@"2.png"]];
LBImageObject *urlImag = [LBImageObject objectWithImageUrl:[NSURL URLWithString:@"https://image-static.segmentfault.com/419/538/4195380633-58e8f762b0d73_articlex"]];
LBImageObject *imag3 = [LBImageObject objectWithImage:[UIImage imageNamed:@"3.jpg"]];

LBPhotoPreviewController *photoPreviewC = [[LBPhotoPreviewController alloc] init];
photoPreviewC.imageObjectArray = @[imag1,imag2,urlImag,imag3];
photoPreviewC.previewScrollView.currentPage = 1;
```
![](https://github.com/A1129434577/LBPhotoPreviewController/blob/master/LBPhotoPreviewController.png?raw=true)
