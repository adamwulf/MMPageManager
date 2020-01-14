//
//  MMPDFDocument+Private.h
//  MMPageManager
//
//  Created by Adam Wulf on 1/8/20.
//  Copyright © 2020 Milestone Made. All rights reserved.
//

#import "MMPDFDocument.h"


@interface MMPDFDocument ()

@property(nonatomic, strong, readonly) PDFDocument *pdfDocument;
@property(nonatomic, strong, readonly) NSOperationQueue *pdfQueue;

@end
