//
//  AppDelegate.m
//  LBTextFieldDemo
//
//  Created by 刘彬 on 2019/9/24.
//  Copyright © 2019 刘彬. All rights reserved.
//

#import "AppDelegate.h"
#import "LBPhotoPreviewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    LBImageObject *imag1 = [LBImageObject objectWithImage:[UIImage imageNamed:@"1.jpg"]];
    LBImageObject *imag2 = [LBImageObject objectWithImage:[UIImage imageNamed:@"2.png"]];
    LBImageObject *urlImag = [LBImageObject objectWithImageUrl:[NSURL URLWithString:@"https://image-static.segmentfault.com/419/538/4195380633-58e8f762b0d73_articlex"]];
    LBImageObject *imag3 = [LBImageObject objectWithImage:[UIImage imageNamed:@"3.jpg"]];
    
    LBPhotoPreviewController *photoPreviewC = [[LBPhotoPreviewController alloc] init];
    photoPreviewC.imageObjectArray = @[imag1,imag2,urlImag,imag3];
//    photoPreviewC.previewScrollView.currentPage = 1;
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:photoPreviewC];
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
