//
//  UIImage+Addition.h
//  
//
//  Created by Nick Hu on 9/16/14.
//  Copyright (c) 2014 Nick Hu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIImage (Addition)

+ (CGSize)scaleSizeOfImage:(UIImage*)image fitMaxWidth:(CGFloat)maxWidth;
+ (CGSize)scaleSizeOfImage:(UIImage*)image fitMaxHeight:(CGFloat)maxHeight;
+ (CGSize)scaleSizeOfImage:(UIImage*)image fitMaxSize:(CGSize)maxSize;
@end
