//
//  ConstantsHfhTests.m
//  HybridFramework_for_HTML5
//
//  Created by Emil Todorov on 4/27/14.
//  Copyright (c) 2014 techzealous. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ConstantsHfh.h"

@interface ConstantsHfhTests : XCTestCase

@end

@implementation ConstantsHfhTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testEscapeSingleQuotesForSql
{
    NSArray *array = @[@"", @"", @"", @""];
    for(int x = 0; x < [array count]; x++) {
        NSString *strEscaped = [ConstantsHfh escapeSingleQuotesForSQL:[array objectAtIndex:x]];
        NSLog(@"%s, %i, strEscaped=%@", __func__, __LINE__, strEscaped);
    }
}

@end
