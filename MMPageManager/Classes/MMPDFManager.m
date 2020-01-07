//
//  MMPDFManager.m
//  infinite-draw
//
//  Created by Adam Wulf on 10/14/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "MMPDFManager.h"

CGFloat const PDFPPI = 72;


@interface MMPDFManager ()

@property(nonatomic, strong, readonly) NSMutableDictionary<NSURL *, PDFDocument *> *openPDFs;

@end


@implementation MMPDFManager

+ (instancetype)sharedManager
{
    static MMPDFManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[MMPDFManager alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init
{
    if (self = [super init]) {
        _openPDFs = [NSMutableDictionary dictionary];
    }
    return self;
}

- (PDFDocument *)pdfDocumentForURL:(NSURL *)pdfURL
{
    PDFDocument *doc = _openPDFs[pdfURL];

    if (!doc) {
        doc = [[PDFDocument alloc] initWithURL:pdfURL];
        _openPDFs[pdfURL] = doc;
    }

    return doc;
}

@end
