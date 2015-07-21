//
//  HCNImagePreviewer.m
//  wolaila
//
//  Created by Nick Hu on 14/12/12.
//  Copyright (c) 2014年 Sudiyi. All rights reserved.
//

#import "HCNImagePreviewer.h"
#import "HCNImageViewer.h"
#import <UIImageView+AFNetworking.h>

@interface HCNImagePreviewer () <HCNImageViewerDelegate>
@end

@implementation HCNImagePreviewer
@synthesize thumbImageUri = _thumbImageUri;

- (id)initWithCoder:(NSCoder*)decoder {
    if (self = [super initWithCoder:decoder]) {
        [self setup];
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *re = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOriginalPhoto)];
    [self addGestureRecognizer:re];
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setThumbImageUri:(NSString *)thumbImageUri
{
    _thumbImageUri = thumbImageUri;
    if (_thumbImageUri != nil) {
        [self setImageWithURL:[NSURL URLWithString:_thumbImageUri] placeholderImage:[UIImage imageNamed:@"icon_placeholder"]];
    }
}

- (NSString *)originImageUri
{
    if (_originImageUri.length == 0) {
        return _thumbImageUri;
    }
    return _originImageUri;
}

- (void)showOriginalPhoto {
    if (!_photoViewer) {
        _photoViewer = [[HCNImageViewer alloc] init];
        _photoViewer.delegate = self;
    }
    
    [_delegate imagePreviewerWillShowPhotoView:self];
    [_photoViewer showWithFromView:self];
}

#pragma mark - HCNImageViewerDelegate
- (void)photoViewDidDisappear {
    _photoViewer = nil;
}
@end
