//
//  QueryParamsSpecs.m
//  DTRequestVerifierExample
//
//  Created by Denys Telezhkin on 13.10.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import "RequestVerifierTestCase.h"

@interface QueryParamsSpecs : RequestVerifierTestCase

@end

@implementation QueryParamsSpecs

- (void)setUp
{
    [super setUp];
    
    self.verifier.host = @"www.foo.com";
    
    NSURL * url = [NSURL URLWithString:@"http://www.foo.com?query=bar&count=5"];
    self.request = [NSMutableURLRequest requestWithURL:url];
    self.verifier.raiseExceptionOnFailure = NO;
}

-(void)testQueryParamsShouldPass
{
    self.verifier.queryParams = @{@"query":@"bar",@"count":@"5"};
    
    XCTAssert([self.verifier verifyRequest:self.request]);
}

-(void)testQueryParamsIsNil
{
    XCTAssertFalse([self.verifier verifyRequest:self.request]);
}

-(void)testQueryParamsIsEmpty
{
    self.verifier.queryParams = @{};
    XCTAssertFalse([self.verifier verifyRequest:self.request]);
}

-(void)testQueryParamsAreWrong
{
    self.verifier.queryParams = @{@"query":@"bar"};
    
    XCTAssertFalse([self.verifier verifyRequest:self.request]);
}

-(void)testDoubleAmpersandsInRequest
{
    NSURL * url = [NSURL URLWithString:@"http://www.foo.com?query=bar&&count=5"];
    self.request = [NSMutableURLRequest requestWithURL:url];
    self.verifier.queryParams = @{@"query":@"bar",@"count":@"5"};
    
    XCTAssertNoThrow([self.verifier verifyRequest:self.request]);
    XCTAssertFalse([self.verifier verifyRequest:self.request]);
}

@end
