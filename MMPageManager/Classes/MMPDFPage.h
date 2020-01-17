//
//  MMPDFPage.h
//  MMPageManager
//
//  Created by Adam Wulf on 1/12/20.
//  Copyright © 2020 Milestone Made. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PDFKit/PDFKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const MMPDFPageDidGenerateThumbnailNotification;

@class MMPDFDocument;


@interface MMPDFPage : NSObject

- (instancetype)initWithPDFPage:(PDFPage *)pdfPage document:(MMPDFDocument *)document;

@property(nonatomic, weak, readonly) MMPDFDocument *document;
@property(nonatomic, assign, readonly) NSUInteger pageIndex;
@property(nonatomic, assign, readonly) CGFloat heightRatio;
@property(nonatomic, assign, readonly) CGFloat pointWidth;
@property(nonatomic, assign, readonly) CGSize idealSize;
@property(nonatomic, strong, readonly) UIImage *thumbnail;
@property(nonatomic, strong, readonly) PDFPage *pdfPage;
@property(nonatomic, assign) CGFloat rotation;

- (void)renderInContext:(CGContextRef)context;
- (void)renderInContext:(CGContextRef)context ignoreRotation:(BOOL)ignoreRotation;

@end

NS_ASSUME_NONNULL_END
