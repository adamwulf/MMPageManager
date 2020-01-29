//
//  MMPDFPage.m
//  MMPageManager
//
//  Created by Adam Wulf on 1/12/20.
//  Copyright © 2020 Milestone Made. All rights reserved.
//

#import "MMPDFPage.h"
#import "MMPDFDocument.h"
#import "MMPDFDocument+Private.h"

NSString *const MMPDFPageDidGenerateThumbnailNotification = @"MMPDFPageDidGenerateThumbnail";


@implementation MMPDFPage {
    CGFloat _rotation;
    UIImage *_thumbnail;
}

- (instancetype)initWithPDFPage:(PDFPage *)pdfPage document:(MMPDFDocument *)document
{
    NSAssert(pdfPage != nil, @"Must have valid page");

    if (self = [super init]) {
        _pdfPage = pdfPage;
        _document = document;
        _pageIndex = [[document pdfDocument] indexForPage:pdfPage];

        // convert to radians
        _rotation = [pdfPage rotation] * M_PI / 180.0;
    }
    return self;
}

- (CGFloat)heightRatio
{
    return [self pointHeight] / [self pointWidth];
}

- (CGFloat)pointHeight
{
    return CGRectGetHeight([[self pdfPage] boundsForBox:kPDFDisplayBoxMediaBox]);
}

- (CGFloat)pointWidth
{
    return CGRectGetWidth([[self pdfPage] boundsForBox:kPDFDisplayBoxMediaBox]);
}

- (CGSize)idealSize
{
    return CGSizeMake([self pointWidth], [self heightRatio] * [self pointWidth]);
}

- (void)setRotation:(CGFloat)rotation
{
    while (rotation >= 2 * M_PI) {
        rotation -= 2 * M_PI;
    }
    while (rotation <= -2 * M_PI) {
        rotation += 2 * M_PI;
    }
    _rotation = rotation;

    [[self pdfPage] setRotation:rotation * 180.0 / M_PI];
}

- (CGFloat)rotation
{
    return _rotation;
}

- (UIImage *)thumbnail
{
    if (!_thumbnail) {
        [self generateThumbnail];
    }
    return _thumbnail;
}

#pragma mark - Private

- (void)generateThumbnail
{
    typeof(self) __weak weakSelf = self;

    [[[self document] pdfQueue] addOperationWithBlock:^{
        MMPDFPage *strongSelf = weakSelf;

        [[self document] doWhileOpen:^{
            if (!strongSelf->_thumbnail) {
                CGFloat scale = [[UIScreen mainScreen] scale];
                CGFloat dim = 300 * scale;
                UIImage *thumb = [[strongSelf pdfPage] thumbnailOfSize:CGSizeMake(dim, dim) forBox:kPDFDisplayBoxMediaBox];

                if ([[self pdfPage] rotation] % 360 == 90) {
                    thumb = [UIImage imageWithCGImage:[thumb CGImage] scale:scale orientation:UIImageOrientationLeft];
                } else if ([[self pdfPage] rotation] % 360 == 180) {
                    thumb = [UIImage imageWithCGImage:[thumb CGImage] scale:scale orientation:UIImageOrientationDown];
                } else if ([[self pdfPage] rotation] % 360 == 270) {
                    thumb = [UIImage imageWithCGImage:[thumb CGImage] scale:scale orientation:UIImageOrientationRight];
                }

                strongSelf->_thumbnail = thumb;
            }
        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:MMPDFPageDidGenerateThumbnailNotification object:strongSelf];
        });
    }];
}

- (void)renderInContext:(CGContextRef)context
{
    [self renderInContext:context ignoreRotation:NO];
}

- (void)renderInContext:(CGContextRef)context ignoreRotation:(BOOL)ignoreRotation
{
    CGContextSaveGState(context);

    CGFloat theta = [[self pdfPage] rotation] % 360;
    CGSize idealSize = [self idealSize];
    CGSize preSize = [self idealSize];

    if (theta == 90 || theta == 270) {
        preSize = CGSizeMake(preSize.height, preSize.width);
    }

    if (ignoreRotation) {
        // Ignore the PDF page's defined rotation, and render it as portrait
        CGContextTranslateCTM(context, idealSize.width / 2, idealSize.height / 2);
        CGContextRotateCTM(context, theta * M_PI / 180.0);
        CGContextTranslateCTM(context, -preSize.width / 2, -preSize.height / 2);
    }

    [[self pdfPage] drawWithBox:kPDFDisplayBoxMediaBox toContext:context];

    CGContextRestoreGState(context);
}

@end
