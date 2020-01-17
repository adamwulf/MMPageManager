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
                UIImage *thumb = [[strongSelf pdfPage] thumbnailOfSize:CGSizeMake(300, 300) forBox:kPDFDisplayBoxMediaBox];

                if ([[self pdfPage] rotation] % 360 == 90) {
                    thumb = [UIImage imageWithCGImage:[thumb CGImage] scale:[thumb scale] orientation:UIImageOrientationLeft];
                } else if ([[self pdfPage] rotation] % 360 == 180) {
                    thumb = [UIImage imageWithCGImage:[thumb CGImage] scale:[thumb scale] orientation:UIImageOrientationDown];
                } else if ([[self pdfPage] rotation] % 360 == 270) {
                    thumb = [UIImage imageWithCGImage:[thumb CGImage] scale:[thumb scale] orientation:UIImageOrientationRight];
                }

                strongSelf->_thumbnail = thumb;
            }
        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:MMPDFPageDidGenerateThumbnailNotification object:strongSelf];
        });
    }];
}

@end
