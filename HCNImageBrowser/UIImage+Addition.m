//
//  UIImage+Addition.m
//  
//
//  Created by Nick Hu on 9/16/14.
//  Copyright (c) 2014 Nick Hu. All rights reserved.
//

#import "UIImage+Addition.h"

@implementation UIImage (Addition)


+ (CGSize)scaleSizeOfImage:(UIImage*)image fitMaxWidth:(CGFloat)maxWidth {
    CGSize scaledSize = image.size;
    if (image.size.width>maxWidth) {
        int height = image.size.height * maxWidth / image.size.width;
        
        scaledSize = CGSizeMake(maxWidth, height);
    }
    
    return scaledSize;
}

+ (CGSize)scaleSizeOfImage:(UIImage*)image fitMaxHeight:(CGFloat)maxHeight {
    CGSize scaledSize = image.size;
    if (image.size.height>maxHeight) {
        int width = image.size.width * maxHeight / image.size.height;
        
        scaledSize = CGSizeMake(width, maxHeight);
    }
    
    return scaledSize;
}

+ (CGSize)scaleSizeOfImage:(UIImage*)image fitMaxSize:(CGSize)maxSize {
    CGSize scaledSize = CGSizeZero;
    if (image.size.width>image.size.height) {
        scaledSize = [UIImage scaleSizeOfImage:image fitMaxWidth:maxSize.width];
        if (scaledSize.height>maxSize.height) {
            scaledSize = [UIImage scaleSizeOfImage:image fitMaxHeight:maxSize.height];
        }
    }
    else {
        scaledSize = [UIImage scaleSizeOfImage:image fitMaxHeight:maxSize.height];
        if (scaledSize.width>maxSize.width) {
            scaledSize = [UIImage scaleSizeOfImage:image fitMaxWidth:maxSize.width];
        }
    }
    return scaledSize;
}
@end
