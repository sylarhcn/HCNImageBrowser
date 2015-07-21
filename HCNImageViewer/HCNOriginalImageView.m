//
//  HCNOriginalImageView.m
//  HCNImageViewerExample
//
//  Created by Nick Hu on 15/7/21.
//  Copyright (c) 2015年 HCN. All rights reserved.
//

#import "HCNOriginalImageView.h"
#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>
#import <SDWebImageManager.h>
@implementation HCNOriginalImageView

#pragma mark - NSURLConnection delegate
/*
 - (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
 {
 
 if ([((NSHTTPURLResponse *)response) statusCode] >= 400) {
 [connection cancel];
 [self showPopupBlockMessage:@"图片加载失败" type:BlockTypeFail close:^{
 [self handleSingleTap:nil];
 }];
 } else {
 expectedLength = response.expectedContentLength;
 [self.progressBar setProgress:offset*1.0f/expectedLength];
 }
 }
 
 - (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
 {
 [imgFileHandle writeData:data];
 offset = [imgFileHandle seekToEndOfFile];
 [self.progressBar setProgress:offset*1.0f/expectedLength];
 }
 
 - (void)connectionDidFinishLoading:(NSURLConnection *)connection
 {
 if (iOS4) {
 self.progressBar.hidden = YES;
 }
 else {
 [self.progressBar hideAnimated:YES];
 }
 
 [imgFileHandle closeFile];
 NSString *path = [[SDImageCache sharedImageCache] cachePathForKey:self.imgUrl];
 [[NSFileManager defaultManager] moveItemAtPath:[path stringByAppendingString:@".tempImg"]
 toPath:path
 error:nil];
 UIImage *image = [UIImage imageWithContentsOfFile:path];
 // Make a FadeIn animation
 CATransition *transition = [CATransition animation];
 transition.duration = 1.0f;
 transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
 transition.type = kCATransitionFade;
 
 [self.imageView.layer addAnimation:transition forKey:nil];
 
 self.photo = image;
 self.imageView.image = self.photo;
 [self resizePhoto];
 }
 
 - (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
 {
 [SVProgressHUD showErrorWithStatus:@"图片加载失败"];
 [self handleSingleTap:nil];
 }*/

- (void)showPhoto {
    // if imgUrl is NULL, show default image
    NSString *imgUrl = self.originalImageUriArray[_currentIndex];
    if (![imgUrl containStringLegacy:@" "]) {
        //        self.currentImageView.image = self.currentImage;
        [self resizePhoto];
    }
    else {
        __weak HCNImageViewer *weak_self = self;
        [self.currentImageView sd_setImageWithURL:[NSURL URLWithString:imgUrl]
                                        completed:^(UIImage *image,
                                                    NSError *error,
                                                    SDImageCacheType cacheType,
                                                    NSURL *imageURL) {
                                            if (error) {
                                                [SVProgressHUD showErrorWithStatus:@"图片加载失败"];
                                                [weak_self handleSingleTap:nil];
                                            } else {
                                                //                                                     _currentImage = image;
                                            }
                                        }];
    }
}

- (void)downloadImage {
    /* 短点续传，有问题，暂时停掉
     SDWebImageManager *webImgManager = [SDWebImageManager sharedManager];
     UIImage *cachedImage = [webImgManager imageWithURL:[NSURL URLWithString:self.imgUrl]];
     
     //缓存文件路径
     NSString *temporyPath = [[[SDImageCache sharedImageCache] cachePathForKey:self.imgUrl] stringByAppendingString:@".tempImg"];
     if (cachedImage) {
     //是否已经下载过的图
     self.photo = cachedImage;
     self.imageView.image = self.photo;
     [self resizePhoto];
     }
     else if (![[NSFileManager defaultManager] fileExistsAtPath:temporyPath]) {
     //如果没有缓存文件，创建一个
     BOOL createSucces = [[NSFileManager defaultManager] createFileAtPath:temporyPath contents:nil attributes:nil];
     if (!createSucces)
     LOG(@"CREAT IMG TEMP FILE FAILED");
     }
     if ([[NSFileManager defaultManager] fileExistsAtPath:temporyPath])
     {
     //有临时文件的，继续下载
     [self.view bringSubviewToFront:self.progressView];
     self.progressView.hidden = NO;
     [self.progressView fadeIn:.3 delegate:nil];
     
     imgFileHandle = [NSFileHandle fileHandleForWritingAtPath:temporyPath];
     offset = [imgFileHandle seekToEndOfFile];
     NSString *range = [NSString stringWithFormat:@"bytes=%llu-",offset];
     NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.imgUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
     [req addValue:range forHTTPHeaderField:@"Range"];
     _imgConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
     [self.imgConnection start];
     }
     */
}
@end
