//
//  RequestVerifierTestCase.h
//  DTRequestVerifierExample
//
//  Created by Denys Telezhkin on 12.10.13.
//  Copyright (c) 2013 Denys Telezhkin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DTRequestVerifier.h"

@interface RequestVerifierTestCase : XCTestCase

@property (nonatomic, strong) DTRequestVerifier * verifier;
@property (nonatomic, strong) NSURLRequest * request;

@end
