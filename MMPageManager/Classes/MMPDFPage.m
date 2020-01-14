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

NSString *const MMPDFPageDidGenerateThumbnail = @"MMPDFPageDidGenerateThumbnail";


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
        typeof(self) __weak weakSelf = self;

        [[[self document] pdfQueue] addOperationWithBlock:^{
            MMPDFPage *strongSelf = weakSelf;

            if (!strongSelf->_thumbnail) {
                strongSelf->_thumbnail = [[strongSelf pdfPage] thumbnailOfSize:CGSizeMake(300, 300) forBox:kPDFDisplayBoxMediaBox];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:MMPDFPageDidGenerateThumbnail object:strongSelf];
            });
        }];
    }
    return _thumbnail;
}

@end
