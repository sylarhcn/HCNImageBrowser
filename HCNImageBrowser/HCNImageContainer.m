//
//  HCNImageContainer.m
//  ZaiChengdu
//
//  Created by Nick Hu on 15/8/4.
//  Copyright (c) 2015年 DigitalChina. All rights reserved.
//

#import "HCNImageContainer.h"
//#import "UIImage+Addition.h"
#import <SDImageCache.h>
#import <UIImageView+WebCache.h>
#import <SVProgressHUD.h>
@interface HCNImageContainer ()
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
//TODO: 独立下载，短点续传，和SDWebImage解耦
//@property (nonatomic,strong) NSMutableData *downloadData;
//@property (nonatomic,strong) NSFileHandle *imgFileHandle;
//@property (nonatomic,strong) NSURLConnection *imgConnection;
@end

@implementation HCNImageContainer

#pragma mark - life cycle
- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.scrollView];
        [self addSubview:self.indicator];
        [self setupGesture];
    }
    return self;
}

- (void)setupGesture {
    UITapGestureRecognizer *doubleTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleDoubleTap:)];
    
    [doubleTap setNumberOfTapsRequired:2];
    [self addGestureRecognizer:doubleTap];
    
    UILongPressGestureRecognizer *longPressRecognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(showActionSheet:)];
    
    longPressRecognizer.minimumPressDuration = .6;
    [self addGestureRecognizer:longPressRecognizer];
    
    UITapGestureRecognizer *singleTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    
    [singleTap setNumberOfTapsRequired:1];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:singleTap];
}

#pragma mark - public fuctions
- (void)setThumbImageURLString:(NSString *)thumbURL originImageURLString:(NSString *)originURL {
    UIImage *img;
    img = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:thumbURL];
    if (!img) {
#warning defaultImage
//        img = [UIImage defaultImageWithSize:CGSizeMake(80, 80)];
    }
    
    if (originURL.length != 0) {
        [_indicator startAnimating];
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:originURL]
                          placeholderImage:img
                                 completed:^(UIImage *image,
                                             NSError *error,
                                             SDImageCacheType
                                             cacheType,
                                             NSURL *imageURL) {
                                     [_indicator stopAnimating];
                                 }];
    } else {
        self.imageView.image = img;
    }
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

#pragma mark - actions
- (void)handleSingleTap:(UIGestureRecognizer*)gesture {
    [self.delegate HCNImageContainerDimiss:self];
}
- (void)handleDoubleTap:(UIGestureRecognizer*)gesture {
    //    if (self.scrollView.zoomScale != self.scrollView.minimumZoomScale) {
    //        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    //    } else {
    //        [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
    //    }
    CGPoint touchPoint = [gesture locationInView:self];
    if (self.scrollView.zoomScale <= 1.0) {
        
        CGFloat scaleX = touchPoint.x + self.scrollView.contentOffset.x;//需要放大的图片的X点
        CGFloat sacleY = touchPoint.y + self.scrollView.contentOffset.y;//需要放大的图片的Y点
        [self.scrollView zoomToRect:CGRectMake(scaleX, sacleY, 10, 10) animated:YES];
        
    } else {
        [self.scrollView setZoomScale:1.0 animated:YES]; //还原
    }
}

- (void)showActionSheet:(UIGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"保存到相册", nil];
        actionSheet.actionSheetStyle = UIBarStyleBlackTranslucent;
        [actionSheet showInView:self];
    }
}

#pragma mark - UIActionSheetDelegate methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [SVProgressHUD showWithStatus:@"正在保存中"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
        });
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image
       didFinishSavingWithError:(NSError *)error
                    contextInfo:(void *)contextInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"保存失败"];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"图片已保存到你的相册中"];
        }
    });
}


#pragma mark - UIScrollViewDelegate methods
- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView {
    return self.imageView;
}

#pragma mark - getter/setter
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGRect rect = frame;
    rect.origin = CGPointMake(0, 0);
    _scrollView.frame = rect;
    _scrollView.contentSize = rect.size;
    _imageView.size = [UIImage scaleSizeOfImage:_imageView.image
                                     fitMaxSize:frame.size];
    _imageView.center = CGPointMake(rect.size.width/2, rect.size.height/2);
    _indicator.center = _imageView.center;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, 0, 0 , 0);
        [_scrollView addSubview:self.imageView];
        _scrollView.delegate = self;
        _scrollView.directionalLockEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 4.0;
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    return _scrollView;
}


- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

- (UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicator.hidesWhenStopped = YES;
        [_indicator stopAnimating];
    }
    return _indicator;
}



/**
 *  断点续传相关
 */
/*
#pragma mark - NSURLConnection delegate

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
 }

#pragma mark - private functions
- (void)showPhoto {
    // if imgUrl is NULL, show default image
    NSString *imgUrl = self.originalImageUriArray[_currentIndex];
    if (![imgUrl containStringLegacy:@" "]) {
        //        self.currentImageView.image = self.currentImage;
        [self resizePhoto];
    }
    else {
        __weak HCNPhotoView *weak_self = self;
        [self.currentImageView.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl]
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

- (void)resizePhoto {
    CGSize size = _currentImageView.imageView.image.size;
    if (size.width >= 320 || size.height >= SCREEN_HEIGHT) {
        self.scrollView.maximumZoomScale = 3;
    }
    else {
        if (size.width >= 320) {
            self.scrollView.maximumZoomScale = 320 / size.width;
        }
        else {
            self.scrollView.maximumZoomScale = SCREEN_HEIGHT / size.height;
        }
    }
    CGFloat rateH = (size.height  > self.height) ? self.height/size.height : 1.0f;
    CGFloat rateW = (size.width > self.width) ? self.width/size.width : 1.0f;
    CGFloat rate = (rateH < rateW) ? rateH : rateW;
    size.height = size.height * rate;
    size.width = size.width * rate;
    [self.currentImageView setSize:size];
    self.currentImageView.center = self.center;
}

- (void)downloadImage {
    // 短点续传，有问题，暂时停掉
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
 
}*/

@end
