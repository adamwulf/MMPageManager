//
//  MMPageManagerTests.m
//  MMPageManagerTests
//
//  Created by Adam Wulf on 1/8/20.
//  Copyright © 2020 Milestone Made. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <MMPageManager/MMPageManager.h>


@interface MMPageManagerTests : XCTestCase

@end


@implementation MMPageManagerTests

- (MMPDFDocument *)normalPDF
{
    return [[MMPDFManager sharedManager] pdfDocumentForURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"Normal" withExtension:@"pdf"]];
}

- (MMPDFDocument *)encryptedPDF
{
    return [[MMPDFManager sharedManager] pdfDocumentForURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"Encrypted" withExtension:@"pdf"]];
}

- (void)testNormalPDF
{
    // Put setup code here. This method is called before the invocation of each test method in the class.
    MMPDFDocument *pdfDocument = [self normalPDF];

    XCTAssertNotNil(pdfDocument, @"Loaded a PDF");
    XCTAssertFalse([pdfDocument isEncrypted], @"not encrypted");
    XCTAssertEqualObjects([pdfDocument title], @"Normal");
    XCTAssertEqual([pdfDocument pageCount], 1, @"one page");
}

- (void)testEncryptedPDF
{
    // Put setup code here. This method is called before the invocation of each test method in the class.
    MMPDFDocument *pdfDocument = [self encryptedPDF];

    XCTAssertNotNil(pdfDocument, @"Loaded a PDF");
    XCTAssertTrue([pdfDocument isEncrypted], @"encrypted");
    XCTAssertEqual([pdfDocument pageCount], 3, @"one page");

    // can't get title
    XCTAssertNil([pdfDocument title], @"Normal");

    [pdfDocument doWhileOpen:^{
        XCTAssertFalse([pdfDocument attemptToDecrypt:@"failure"], @"wrong password");
        XCTAssertTrue([pdfDocument isEncrypted], @"encrypted");

        XCTAssertTrue([pdfDocument attemptToDecrypt:@"password"], @"correct password");
        XCTAssertFalse([pdfDocument isEncrypted], @"decrypted");
    }];
}

- (void)testNewPDFPage
{
    NSString *tmp = NSTemporaryDirectory();
    NSURL *tmpURL = [[NSURL fileURLWithPath:tmp] URLByAppendingPathComponent:@"temp.pdf"];

    PDFDocument *doc = [[PDFDocument alloc] init];

    XCTAssertEqual([doc pageCount], 0);

    [doc insertPage:[[PDFPage alloc] init] atIndex:0];

    XCTAssertEqual([doc pageCount], 1);

    [[doc pageAtIndex:0] setBounds:CGRectMake(0, 0, 72, 72) forBox:kPDFDisplayBoxMediaBox];

    PDFAnnotation *annotation = [[PDFAnnotation alloc] initWithBounds:CGRectMake(0, 0, 72, 72) forType:PDFAnnotationSubtypeInk withProperties:nil];
    PDFBorder *border = [[PDFBorder alloc] init];
    [border setLineWidth:4];

    [annotation addBezierPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(10, 10, 20, 20)]];
    [annotation setColor:[UIColor redColor]];
    [annotation setBorder:border];

    [[doc pageAtIndex:0] addAnnotation:annotation];

    [doc writeToURL:tmpURL];
}

- (void)testEmptyPDF
{
    NSString *tmp = NSTemporaryDirectory();
    NSURL *tmpURL = [[NSURL fileURLWithPath:tmp] URLByAppendingPathComponent:@"temp.pdf"];

    PDFDocument *doc = [[PDFDocument alloc] init];

    XCTAssertEqual([doc pageCount], 0);

    [doc writeToURL:tmpURL];

    doc = [[PDFDocument alloc] initWithURL:tmpURL];

    XCTAssertEqual([doc pageCount], 0);
}

@end
