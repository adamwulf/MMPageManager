//
//  MMPDFDocument.h
//  LooseLeaf
//
//  Created by Adam Wulf on 5/9/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PDFKit/PDFKit.h>


@interface MMPDFDocument : NSObject

@property(nonatomic, readonly) NSURL *urlOnDisk;
@property(nonatomic, readonly) NSUInteger pageCount;
@property(nonatomic, readonly) NSString *title;

// the ppi used for PDF contexts
+ (CGFloat)ppi;

- (instancetype)initWithURL:(NSURL *)url;

- (BOOL)attemptToDecrypt:(NSString *)password;

- (BOOL)isEncrypted;

- (PDFDocument *)openPDF;
- (void)closePDF;

- (void)doWhileOpen:(void (^)(void))block;

@end
