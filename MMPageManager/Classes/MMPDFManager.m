//
//  MMPDFManager.m
//  infinite-draw
//
//  Created by Adam Wulf on 10/14/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "MMPDFManager.h"
#import "MMPDFDocument.h"

CGFloat const PDFPPI = 72;


@interface MMPDFManager ()

@property(nonatomic, strong, readonly) NSMutableDictionary<NSURL *, MMPDFDocument *> *cachedPDFs;

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
        _cachedPDFs = [NSMutableDictionary dictionary];
    }
    return self;
}

- (MMPDFDocument *)pdfDocumentForURL:(NSURL *)pdfURL
{
    MMPDFDocument *doc = _cachedPDFs[pdfURL];

    if (!doc) {
        doc = [[MMPDFDocument alloc] initWithURL:pdfURL];

        if (doc) {
            _cachedPDFs[pdfURL] = doc;
        }
    }

    return doc;
}

@end
