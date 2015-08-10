//
//  HCNPhotoView.m
//  
//
//  Created by Nick Hu on 14/12/12.
//  Copyright (c) 2014年 Sudiyi. All rights reserved.
//

#import "HCNPhotoView.h"
//#import "NSString+Addition.h"
#import "UIImage+Addition.h"
#import "HCNImageContainer.h"
//#import "DCFunctions.h"

#import <SVProgressHUD.h>
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>
#import <SDWebImageManager.h>

#define kAnimationDuration  1.4f

@interface HCNPhotoView ()<UIScrollViewDelegate,HCNImageContainerDelegate>
{
    unsigned long long _expectedLength;
    unsigned long long _offset;
    CGRect _fromRect;
    NSMutableArray *_reuseViewArray;
    NSMutableArray *_usingViewArray;
}
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) HCNImageContainer *currentImageView;
@property (nonatomic,assign) NSInteger count;
@property (nonatomic,strong) UILabel *countLabel;
/**
 *  //缩略图的对象，可以是urlstring，也可以是UIImage，但是只会尝试在缓存中寻找这个urlstring，不会去下载
 */
@property (nonatomic, strong) NSArray *thumbImageUriArray;
/**
 *  原图对象，可以是urlstring，也可以是UIImage，urlstring时将会去下载
 */
@property (nonatomic, strong) NSArray *originalImageUriArray;
@end

@implementation HCNPhotoView

#pragma mark - lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupScrollView];
    [self setupDataSource];
    [self showAnimation];
}

#pragma mark - private function
- (void)setupScrollView {
    self.view.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    CGRect rect = self.view.frame;
    rect.size.width += 10;//每页之间的间隙
    self.scrollView.frame = rect;
    [self.view addSubview:self.scrollView];
    
    self.countLabel.frame = CGRectMake(0, self.view.bounds.size.height - 20, self.view.bounds.size.width, 20);
    [self.view addSubview:self.countLabel];
}

- (void)setupDataSource {
    if (!_thumbImageUriArray && [_dataSource respondsToSelector:@selector(photoViewThumbImageData:)]) {
        self.thumbImageUriArray = [_dataSource photoViewThumbImageData:self];
    }
    if (!_originalImageUriArray && [_dataSource respondsToSelector:@selector(photoViewOriginalImageData:)]) {
        self.originalImageUriArray = [_dataSource photoViewOriginalImageData:self];
    }
}


- (void)setupImageViews {
    CGFloat width = self.scrollView.bounds.size.width;
    CGSize size = self.scrollView.contentSize;
    size.width = width * self.count;
    size.height = self.view.bounds.size.height;
    self.scrollView.contentSize = size;
    if (_usingViewArray == nil) {
        _usingViewArray = [@[] mutableCopy];
    }
    
    for (int i = 0; i < _thumbImageUriArray.count; i++) {
        HCNImageContainer *imgView = [self createImageViewWithIndex:i];
        imgView.delegate = self;
        [self.scrollView addSubview:imgView];
        [_usingViewArray addObject:imgView];
    }
}

- (UIView *)getParsentView:(UIView *)view{
    if ([[view nextResponder] isKindOfClass:[UIViewController class]] || view == nil) {
        return view;
    }
    return [self getParsentView:view.superview];
}

- (void)close {
    if ([self.delegate respondsToSelector:@selector(photoViewDidDisappear)]) {
        [self.delegate photoViewDidDisappear];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [self dismissViewControllerAnimated:NO completion:nil];
    [self closeAnimation];
}

- (void)closeAnimation {
    if ([self.delegate respondsToSelector:@selector(photoView:SourceViewWithIndex:)]) {
        UIView *sourceView = [self.delegate photoView:self SourceViewWithIndex:self.currentIndex];
        UIView *parentView = [self getParsentView:sourceView];
        CGRect rect = [sourceView.superview convertRect:sourceView.frame toView:parentView];
        
        //如果是tableview，要减去偏移量
        if ([parentView isKindOfClass:[UITableView class]]) {
            UITableView *tableview = (UITableView *)parentView;
            rect.origin.y =  rect.origin.y - tableview.contentOffset.y;
        }
        if ([[parentView nextResponder] isKindOfClass:[UIViewController class]]) {
            UIViewController *con = (UIViewController *)[parentView nextResponder];
            if (!con.navigationController.navigationBar.translucent) {
                //加上statusBar的和navibar偏移
                rect.origin.y = rect.origin.y + 64;
            }
        }
        UIImageView *animationView = [[UIImageView alloc] initWithFrame:self.currentImageView.imageView.frame];
        animationView.image = self.currentImageView.imageView.image;

        [self.view.window addSubview:animationView];
        [UIView animateWithDuration:kAnimationDuration
                         animations:^{
                             animationView.frame = rect;
                         }
                         completion:^(BOOL finished) {
                             [animationView removeFromSuperview];
                         }];
    } else {
        [self fadeOutAnimation];
    }
}

- (void)showAnimation {
    self.scrollView.contentOffset = CGPointMake(self.scrollView.bounds.size.width*self.currentIndex, 0);
    if ([self.delegate respondsToSelector:@selector(photoView:SourceViewWithIndex:)]) {
        UIView *sourceView = [self.delegate photoView:self SourceViewWithIndex:self.currentIndex];
        UIView *parentView = [self getParsentView:sourceView];
        CGRect rect = [sourceView.superview convertRect:sourceView.frame toView:parentView];
        //如果是tableview，要减去偏移量
        if ([parentView isKindOfClass:[UITableView class]]) {
            UITableView *tableview = (UITableView *)parentView;
            rect.origin.y =  rect.origin.y - tableview.contentOffset.y;
        }
        if ([[parentView nextResponder] isKindOfClass:[UIViewController class]]) {
            UIViewController *con = (UIViewController *)[parentView nextResponder];
            if (!con.navigationController.navigationBar.translucent) {
                //加上statusBar的和navibar偏移
                rect.origin.y = rect.origin.y + 64;
            }
        }
        self.currentImageView.imageView.frame = rect;
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        CGSize size = [UIImage scaleSizeOfImage:self.currentImageView.imageView.image
                                     fitMaxSize:CGSizeMake(320, screenHeight)];
        [UIView animateWithDuration:kAnimationDuration
                         animations:^{
                             self.view.backgroundColor = [UIColor blackColor];
                             self.currentImageView.imageView.frame = CGRectMake((320-size.width)/2,
                                                                                (screenHeight-size.height)/2,
                                                                                size.width,
                                                                                size.height);
                         }];
    } else {
        [self fadeInAnimation];
    }
}

- (void)fadeOutAnimation {
    UIImageView *animationView = [[UIImageView alloc] initWithFrame:self.currentImageView.imageView.frame];
    animationView.image = self.currentImageView.imageView.image;
    [self.view.window addSubview:animationView];
    [UIView animateWithDuration:0.3
                     animations:^{
                         animationView.alpha = 0;
                         animationView.backgroundColor = [UIColor clearColor];
                     }];
    
}

- (void)fadeInAnimation {
    self.currentImageView.alpha = 0;
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.view.backgroundColor = [UIColor blackColor];
                         self.currentImageView.alpha = 1;
                     }];
}


#pragma mark - public functions
- (void)show {
    [[[[UIApplication sharedApplication] keyWindow] rootViewController]
     presentViewController:self
     animated:NO
     completion:^{
        [self showAnimation];
     }];
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat width = scrollView.bounds.size.width;
    self.currentIndex = floor((scrollView.contentOffset.x - width / 2) / width)+1;
}

- (HCNImageContainer *)createImageViewWithIndex:(NSInteger)i {
    id obj = _thumbImageUriArray[i];
    HCNImageContainer *imageContianer = [[HCNImageContainer alloc] init];
    if ([obj isKindOfClass:[NSString class]]) {
        NSString *origin = nil;
        if ([_originalImageUriArray count] > i) {
            if ([_originalImageUriArray[i] isKindOfClass:[NSString class]]) {
                origin = _originalImageUriArray[i];
            }
        }
        [imageContianer setThumbImageURLString:(NSString *)obj
                          originImageURLString:origin];
    } else if ([obj isKindOfClass:[UIImage class]]) {
        [imageContianer setImage:(UIImage *)obj];
    }
    imageContianer.frame = CGRectMake(self.scrollView.bounds.size.width*i,
                                      0,
                                      self.scrollView.bounds.size.width -10,
                                      self.scrollView.bounds.size.height);
    return imageContianer;
}

- (UIImage *)thumbImageOfIndex:(NSInteger )i {
    NSObject *obj = _thumbImageUriArray[i];
    if ([obj isKindOfClass:[UIImage class]]) {
        return (UIImage *)obj;
    } else if ([obj isKindOfClass:[NSString class]]) {
        UIImage *img = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:(NSString *)obj];
        if (!img) {
            img = [UIImage imageNamed:@"picture"];//没有图片时的默认placeholder
        }
        return img;
    }
    return nil;
}

#pragma mark - HCNImageContainerDelegate
- (void)HCNImageContainerDimiss:(HCNImageContainer *)container {
    [self close];
}

#pragma mark - setter/geter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
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
        _countLabel.text = [NSString stringWithFormat:@"%ld/%ld",_currentIndex+1,(long)self.count];
    }
}

- (void)setThumbImageUriArray:(NSArray *)thumbImageUriArray {
    _thumbImageUriArray = thumbImageUriArray;
    [self setupImageViews];
}

- (HCNImageContainer *)currentImageView {
    return _usingViewArray[_currentIndex];
}

@end