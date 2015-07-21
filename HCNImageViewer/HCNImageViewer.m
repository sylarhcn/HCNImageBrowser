//
//  HCNImageViewer.m
//  
//
//  Created by Nick Hu on 14/12/12.
//  Copyright (c) 2014年 Sudiyi. All rights reserved.
//

#import "HCNImageViewer.h"
//#import "NSString+Addition.h"
//#import "UIImage+Addition.h"
#import <SVProgressHUD.h>
#define kAnimationDuration  0.3

@interface HCNImageViewer ()<UIActionSheetDelegate,UIScrollViewDelegate,NSURLConnectionDataDelegate>
{
    unsigned long long _expectedLength;
    unsigned long long _offset;
    CGRect _fromRect;
    NSMutableArray *_reuseViewArray;
    NSMutableArray *_usingViewArray;
}
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIImageView *currentImageView;
@property (nonatomic,strong) UIView *imageContainerView;
@property (nonatomic,assign) NSInteger count;
@property (nonatomic,strong) UILabel *countLabel;
//TODO: 独立下载，短点续传，和SDWebImage解耦
//@property (nonatomic,strong) NSMutableData *downloadData;
//@property (nonatomic,strong) NSFileHandle *imgFileHandle;
//@property (nonatomic,strong) NSURLConnection *imgConnection;
@end

@implementation HCNImageViewer

#pragma mark - lifecycle
- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.frame = window.bounds;
    self.imageContainerView.frame = self.frame;
    self.scrollView.frame = self.frame;
    [self.scrollView addSubview:self.imageContainerView];
    [self addSubview:self.scrollView];
    
    self.countLabel.frame = CGRectMake(0, self.bounds.size.height - 20, self.bounds.size.width, 20);
    [self addSubview:self.countLabel];
    
    [self setupGestures];
}

- (void)setupGestures {
    // setup gestures
    UITapGestureRecognizer *tripleTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleTripleTap:)];
    
    [tripleTap setNumberOfTapsRequired:3];
    [self addGestureRecognizer:tripleTap];
    
    UITapGestureRecognizer *doubleTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleDoubleTap:)];
    
    [doubleTap setNumberOfTapsRequired:2];
    [doubleTap requireGestureRecognizerToFail:tripleTap];
    [self addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    
    [singleTap setNumberOfTapsRequired:1];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:singleTap];
    
    UILongPressGestureRecognizer *longPressRecognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(showActionSheet:)];
    
    longPressRecognizer.minimumPressDuration = .6;
    [self addGestureRecognizer:longPressRecognizer];
}

- (void)setupImageViews {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGSize size = self.scrollView.contentSize;
    size.width = width * self.count;
    size.height = self.bounds.size.height;
    self.scrollView.contentSize = size;
    if (_usingViewArray == nil) {
        _usingViewArray = [@[] mutableCopy];
    }
    
    for (int i = 0; i < _thumbImageUriArray.count; i++) {
        UIImageView *imgView = [self createImageViewWithUri:_thumbImageUriArray[i]];
        imgView.image = [self thumbImageOfIndex:i];
        CGSize size = [UIImage scaleSizeOfImage:imgView.image fitMaxSize:CGSizeMake(width-2, height-2)];
        imgView.frame = CGRectMake(width*i+1, (height - size.height)/2, size.width, size.height);
        [self.scrollView addSubview:imgView];
        [_usingViewArray addObject:imgView];
    }
}

- (void)afterFadeOut {
    
    if ([self.delegate respondsToSelector:@selector(photoViewDidDisappear)]) {
        [self.delegate photoViewDidDisappear];
    }
    [self removeFromSuperview];
}

#pragma mark - actions

- (void)handleSingleTap:(UIGestureRecognizer*)gesture {
    // remove progress bar
//    [self.imgConnection cancel];
    
    // Close viewer;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.currentImageView.layer.backgroundColor = [UIColor clearColor].CGColor;
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self afterFadeOut];
    }];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)handleDoubleTap:(UIGestureRecognizer*)gesture {
    if (self.scrollView.zoomScale != self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
    }
}

- (void)handleTripleTap:(UIGestureRecognizer*)gesture {}

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
        UIImageWriteToSavedPhotosAlbum(self.currentImageView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    }
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image
       didFinishSavingWithError:(NSError *)error
                    contextInfo:(void *)contextInfo {
    if (error) {
        [SVProgressHUD showErrorWithStatus:@"保存失败"];
    } else {
        [SVProgressHUD showSuccessWithStatus:@"图片已保存到你的相册中"];
    }
}

#pragma mark - UIScrollViewDelegate methods
//- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView {
//    return self.imageContainerView;
////    return self.currentImageView;
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat width = scrollView.bounds.size.width;
    self.currentIndex = floor((scrollView.contentOffset.x - width / 2) / width)+1;
}

//- (void)scrollViewDidEndZooming:(UIScrollView*)scrollView withView:(UIView*)view atScale:(float)scale {
//    CGAffineTransform transform = CGAffineTransformIdentity;
//    transform = CGAffineTransformScale(transform, scale, scale);
//    view.transform = transform;
//}



#pragma mark - private functions


- (void)resizePhoto {
    CGSize size = _currentImageView.image.size;
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



- (UIImageView *)createImageViewWithUri:(NSString *)uri {
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = YES;
    return imageView;
}

- (UIImage *)thumbImageOfIndex:(NSInteger )i {
    UIImage *img = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_thumbImageUriArray[i]];
    if (!img) {
        img = [UIImage imageNamed:@"picture"];//没有图片时的默认placeholder
    }
    return img;
}

#pragma mark - public functions
- (void)showWithFromView:(UIView *)view {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH*self.currentIndex, 0);
    if (self.superview == nil) {
        [window addSubview:self];
    }
    self.currentImageView.alpha = 0;
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundColor = [UIColor blackColor];
        self.currentImageView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - setter/geter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.directionalLockEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 4.0;
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        _scrollView.pagingEnabled = YES;
    }
    return _scrollView;
}

- (UIView *)imageContainerView {
    if (!_imageContainerView) {
        _imageContainerView = [[UIView alloc] init];
    }
    return _imageContainerView;
}

- (NSInteger)count {
    if (_thumbImageUriArray) {
        return _thumbImageUriArray.count;
    } else if (self.originalImageUriArray) {
        return self.originalImageUriArray.count;
    }
    return 0;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.font = [UIFont systemFontOfSize:14];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _countLabel;
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    if (_countLabel) {
        _countLabel.text = [NSString stringWithFormat:@"%d/%d",_currentIndex+1,self.count];
    }
}

- (void)setThumbImageUriArray:(NSArray *)thumbImageUriArray {
    _thumbImageUriArray = thumbImageUriArray;
    [self setupImageViews];
}

- (UIImageView *)currentImageView {
    return _usingViewArray[_currentIndex];
}
@end