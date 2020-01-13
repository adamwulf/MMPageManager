//
//  MMPDFPage.m
//  MMPageManager
//
//  Created by Adam Wulf on 1/12/20.
//  Copyright © 2020 Milestone Made. All rights reserved.
//

#import "MMPDFPage.h"


@implementation MMPDFPage {
    CGFloat _rotation;
    UIImage *_thumbnail;
}

- (instancetype)initWithPDFPage:(PDFPage *)pdfPage
{
    if (self = [super init]) {
        _pdfPage = pdfPage;

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
        _thumbnail = [[self pdfPage] thumbnailOfSize:[self idealSize] forBox:kPDFDisplayBoxMediaBox];
    }
    return _thumbnail;
}

@end
