//
//  MMPDFDocument.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/9/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PDFKit/PDFKit.h>

@class MMPDFPage;


@interface MMPDFDocument : NSObject

@property(nonatomic, readonly) NSURL *urlOnDisk;
@property(nonatomic, readonly) NSUInteger pageCount;
@property(nonatomic, readonly) NSString *title;

// the ppi used for PDF contexts
+ (CGFloat)ppi;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithURL:(NSURL *)pdfURL keepOpen:(BOOL)keepOpen;
- (instancetype)initWithPDFDocument:(PDFDocument *)pdfDocument;

- (BOOL)isEncrypted;
- (BOOL)attemptToDecrypt:(NSString *)password;

- (BOOL)openPDF;
- (void)closePDF;
- (void)doWhileOpen:(void (^)(void))block;

- (MMPDFPage *)pageAtIndex:(NSUInteger)index;

@end
