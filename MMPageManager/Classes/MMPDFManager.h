//
//  MMPDFManager.h
//  infinite-draw
//
//  Created by Adam Wulf on 10/14/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PDFKit/PDFKit.h>

NS_ASSUME_NONNULL_BEGIN

extern CGFloat const PDFPPI;

@class MMPDFDocument;


@interface MMPDFManager : NSObject

+ (instancetype)sharedManager;
- (instancetype)init NS_UNAVAILABLE;

- (MMPDFDocument *)pdfDocumentForURL:(NSURL *)pdfURL;

@end

NS_ASSUME_NONNULL_END
