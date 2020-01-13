//
//  MMPDFDocument.m
//  LooseLeaf
//
//  Created by Adam Wulf on 5/9/16.
//  Copyright © 2016 Milestone Made, LLC. All rights reserved.
//

#import "MMPDFDocument.h"
#import "MMPDFPage.h"

NSString *kPDFDefaultPassword = @"";


@implementation MMPDFDocument {
    BOOL _isEncrypted;
    NSString *_password;
    PDFDocument *_pdfDocument;
    NSInteger _numOpened;
    NSDictionary<PDFDocumentAttribute, id> *_attributes;
}

@synthesize pageCount = _pageCount;
@synthesize urlOnDisk = _urlOnDisk;

+ (CGFloat)ppi
{
    return 72;
}

- (instancetype)initWithURL:(NSURL *)pdfURL
{
    return [self initWithURL:pdfURL keepOpen:NO];
}

- (instancetype)initWithURL:(NSURL *)pdfURL keepOpen:(BOOL)keepOpen
{
    PDFDocument *document = [[PDFDocument alloc] initWithURL:pdfURL];

    if (!document) {
        return nil;
    }

    if (self = [self initWithPDFDocument:document]) {
        if (!keepOpen) {
            [self closePDF];
        }
    }
    return self;
}

- (instancetype)initWithPDFDocument:(PDFDocument *)pdfDocument
{
    if (self = [super init]) {
        _urlOnDisk = [pdfDocument documentURL];
        _pdfDocument = pdfDocument;

        if (!_pdfDocument) {
            return nil;
        }

        _pageCount = [_pdfDocument pageCount];
        _isEncrypted = [_pdfDocument isEncrypted];

        if ([self isEncrypted]) {
            // try with a blank password. Apple Preview does this
            // to auto-open encrypted PDFs
            if ([_pdfDocument unlockWithPassword:kPDFDefaultPassword]) {
                _password = kPDFDefaultPassword;
            }
        }

        _attributes = [_pdfDocument documentAttributes];
        _numOpened = 1;
    }
    return self;
}


#pragma mark - Properties

- (PDFDocument *)pdfDocument
{
    return _pdfDocument;
}

- (BOOL)isEncrypted
{
    return _isEncrypted && !_password;
}

- (NSString *)title
{
    return [_attributes objectForKey:PDFDocumentTitleAttribute];
}

#pragma mark - Public Methods

- (BOOL)attemptToDecrypt:(NSString *)password
{
    NSAssert(_pdfDocument != nil, @"PDF document must be open");
    BOOL success = !_isEncrypted || _password != nil;

    if (_isEncrypted && !_password && password) {
        if ([_pdfDocument unlockWithPassword:password]) {
            _password = password;
            _attributes = [_pdfDocument documentAttributes];

            success = YES;
        }
    }

    return success;
}

- (MMPDFPage *)pageAtIndex:(NSUInteger)index
{
    return [[MMPDFPage alloc] initWithPDFPage:[[self pdfDocument] pageAtIndex:index]];
}

#pragma mark Open and Close

- (BOOL)openPDF
{
    @synchronized(self)
    {
        if (!_pdfDocument) {
            _pdfDocument = [[PDFDocument alloc] initWithURL:_urlOnDisk];

            if (!_pdfDocument) {
                return NO;
            }

            if (_password) {
                [_pdfDocument unlockWithPassword:_password];
            }
            _numOpened = 1;
        } else {
            _numOpened += 1;
        }
    }
    return YES;
}

- (void)closePDF
{
    @synchronized(self)
    {
        _numOpened -= 1;

        if (_numOpened == 0) {
            _pdfDocument = nil;
        }
    }
}

- (void)doWhileOpen:(void (^)(void))block
{
    [self openPDF];

    block();

    [self closePDF];
}

@end
