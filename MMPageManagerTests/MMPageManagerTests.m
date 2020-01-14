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

- (void)testEmptyPDF
{
    NSString *tmp = NSTemporaryDirectory();
    NSURL *tmpURL = [[NSURL fileURLWithPath:tmp] URLByAppendingPathComponent:@"temp.pdf"];

    PDFDocument *doc = [[PDFDocument alloc] init];

    XCTAssertEqual([doc pageCount], 0);

    [doc writeToURL:tmpURL];

    doc = [[PDFDocument alloc] initWithURL:tmpURL];

    XCTAssertEqual([doc pageCount], 1);
}

// The following test uses a page from a first PDF document
// and duplicates it into a second PDF as 2 additional pages.
// all changes to that page affect both new pages in the new pdf
- (void)testSharingSinglePDFPage
{
    NSString *tmp = NSTemporaryDirectory();
    NSURL *tmpURL = [[NSURL fileURLWithPath:tmp] URLByAppendingPathComponent:@"temp.pdf"];

    PDFDocument *doc = [[PDFDocument alloc] init];
    PDFPage *page = [[PDFPage alloc] init];

    [page setBounds:CGRectMake(0, 0, 72, 72) forBox:kPDFDisplayBoxMediaBox];

    [doc insertPage:page atIndex:0];

    XCTAssertEqual([doc pageCount], 1);

    [doc writeToURL:tmpURL];

    doc = [[PDFDocument alloc] initWithURL:tmpURL];

    page = [[doc pageAtIndex:0] copy];

    PDFDocument *doc2 = [[PDFDocument alloc] init];

    [doc2 insertPage:page atIndex:0];
    [doc2 insertPage:page atIndex:1];

    PDFAnnotation *annotation = [[PDFAnnotation alloc] initWithBounds:CGRectMake(0, 0, 72, 72) forType:PDFAnnotationSubtypeInk withProperties:nil];
    PDFBorder *border = [[PDFBorder alloc] init];
    [border setLineWidth:4];

    [annotation addBezierPath:[UIBezierPath bezierPathWithOvalInRect:CGRectMake(10, 10, 20, 20)]];
    [annotation setColor:[UIColor redColor]];
    [annotation setBorder:border];

    [page addAnnotation:annotation];

    XCTAssertEqual([doc pageCount], 1);
    XCTAssertEqual([doc2 pageCount], 2);

    [doc2 writeToURL:tmpURL];
}

- (void)testAddingPageMultipleTimes
{
    // Adding the same page to the same document multiple times is allowed

    PDFDocument *doc = [[PDFDocument alloc] init];
    PDFPage *page = [[PDFPage alloc] init];

    [doc insertPage:page atIndex:[doc pageCount]];

    XCTAssertEqual([doc pageCount], 1);

    [doc insertPage:page atIndex:[doc pageCount]];

    XCTAssertEqual([doc pageCount], 2);
}

- (void)testMovingPageToNewDocumentUnsafe
{
    // Adding the same page to the same document multiple times is allowed

    PDFDocument *doc1 = [[PDFDocument alloc] init];
    PDFPage *page = [[PDFPage alloc] init];

    [doc1 insertPage:page atIndex:[doc1 pageCount]];

    XCTAssertEqual([doc1 pageCount], 1);
    XCTAssertEqual([page document], doc1);

    PDFDocument *doc2 = [[PDFDocument alloc] init];

    [doc2 insertPage:page atIndex:[doc2 pageCount]];

    XCTAssertEqual([doc1 pageCount], 1);
    XCTAssertEqual([doc2 pageCount], 1);
    XCTAssertEqual([page document], doc2);

    // !!
    // The document property of a page object is whatever document it's
    // been added to most recently. If a page has been added to multiple
    // documents, then it retains the most recent document
    PDFPage *pageFromDoc1 = [doc1 pageAtIndex:0];

    XCTAssertEqual([pageFromDoc1 document], doc2);
}

- (void)testMovingPageToNewDocumentSafe
{
    // Adding the same page to the same document multiple times is allowed

    PDFDocument *doc1 = [[PDFDocument alloc] init];
    PDFPage *page1 = [[PDFPage alloc] init];

    [doc1 insertPage:page1 atIndex:[doc1 pageCount]];

    XCTAssertEqual([doc1 pageCount], 1);
    XCTAssertEqual([page1 document], doc1);

    PDFDocument *doc2 = [[PDFDocument alloc] init];
    // !!
    // Whenever moving a page between documents, always copy the PDFPage ref
    // so that the original document's page isn't messed up
    PDFPage *page2 = [page1 copy];

    [doc2 insertPage:page2 atIndex:[doc2 pageCount]];

    XCTAssertEqual([doc1 pageCount], 1);
    XCTAssertEqual([doc2 pageCount], 1);
    XCTAssertEqual([page2 document], doc2);
    XCTAssertEqual([page1 document], doc1);

    PDFPage *pageFromDoc1 = [doc1 pageAtIndex:0];

    XCTAssertEqual([pageFromDoc1 document], doc1);
}

- (void)testRemovePage
{
    // Adding the same page to the same document multiple times is allowed

    PDFDocument *doc1 = [[PDFDocument alloc] init];
    PDFPage *page1 = [[PDFPage alloc] init];

    [doc1 insertPage:page1 atIndex:[doc1 pageCount]];

    XCTAssertEqual([doc1 pageCount], 1);
    XCTAssertEqual([page1 document], doc1);

    // Removing a page from a document will NULL its document ref
    [doc1 removePageAtIndex:0];

    XCTAssertEqual([doc1 pageCount], 0);
    XCTAssertEqual([page1 document], NULL);

    [doc1 insertPage:page1 atIndex:[doc1 pageCount]];

    XCTAssertEqual([doc1 pageCount], 1);
    XCTAssertEqual([page1 document], doc1);
}

@end
