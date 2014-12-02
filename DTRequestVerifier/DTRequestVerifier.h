//
//  RequestVerifier.h
//  CommandCenter-iPad
//
//  Created by Denys Telezhkin on 25.09.13.
//  Copyright (c) 2013 MLSDev. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DTBodySerializationType) {
    DTBodySerializationTypeRaw = 1,
    DTBodySerializationTypeJSON,
    DTBodySerializationTypePlist
};

/**
 `DTRequestVerifier` class is used to verify NSURLRequests. Set all desired properties you want to verify on NSURLRequest and call -verifyRequest: method.
 */
@interface DTRequestVerifier : NSObject

/**
 NSURLRequest expected HTTPMethod. Defaults to @"GET".
 */
@property (nonatomic, strong) NSString * HTTPMethod;

/**
 NSURL's expected scheme. Defaults to @"http".
 */
@property (nonatomic, strong) NSString * scheme;

/**
 NSURLRequest expected host.
 */
@property (nonatomic, strong) NSString * host;

/**
 NSURLRequest expected path.
 */
@property (nonatomic, strong) NSString * path;

/**
 NSURLRequest expected HTTPHeaderFields. Only header fields, that are present in this NSDictionary are checked. Other header fields, present on NSURLRequest allHTTPHeaderFields, are ignored.
 */
@property (nonatomic, strong) NSDictionary * HTTPHeaderFields;

/**
 NSURLRequest expected query parameters. All keys and values should be NSStrings, otherwise verification will fail. Query to verify is received from NSURL -query method.
 */
@property (nonatomic, strong) NSDictionary * queryParams;

/**
 NSURLRequest expected body parameters. Three types of serialization supported: raw parameters, JSON and PList data.
 */
@property (nonatomic, strong) NSDictionary * bodyParams;

/**
 Type of serialization to use when serializing HTTPBody data. Defaults to `DTBodySerializationTypeJSON`.
 */
@property (nonatomic, assign) DTBodySerializationType bodySerializationType;

/**
 Set this property to NO if you don't need verification errors log messages to be printed.
 
 Default value is YES.
 */
@property (nonatomic, assign) BOOL loggingEnabled;

/**
 Raise exception if verifyRequest: method fails. 
 
 Default value is YES.
 */
@property (nonatomic, assign) BOOL raiseExceptionOnFailure;

/**
 Creates and returns `DTRequestVerifier` object.
 */
+(instancetype)verifier;

/**
 Verifies passed request, using all properties, that were previously set on `DTRequestVerifier` instance. If verification fails, message explaining error is logged to console, and method returns NO. If all expectations were met, method returns YES.
 
 @param request NSURLRequest object to verify
 @return result of verification
 */
-(BOOL)verifyRequest:(NSURLRequest *)request;

@end
