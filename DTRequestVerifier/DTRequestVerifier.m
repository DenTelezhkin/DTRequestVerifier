//
//  RequestVerifier.m
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

#import "DTRequestVerifier.h"

@interface DTRequestVerifier()
@property (nonatomic, strong) NSURLRequest * request;
@end

@implementation DTRequestVerifier

+(instancetype)verifier
{
    DTRequestVerifier * verifier = [self new];
    
    verifier.HTTPMethod = @"GET";
    verifier.scheme = @"http";
    verifier.loggingEnabled = YES;
    verifier.raiseExceptionOnFailure = YES;
    verifier.path = @"";
    verifier.bodySerializationType = DTBodySerializationTypeJSON;
    
    return verifier;
}

-(void)handleFailureWithReason:(NSString *)message
{
    if (self.raiseExceptionOnFailure)
    {
        NSException * exception = [[NSException alloc] initWithName:@"DTRequestVerifier wrong request"
                                                             reason:message
                                                           userInfo:nil];
        [exception raise];
    }
    if (self.loggingEnabled)
    {
        NSLog(@"DTRequestVerifier. Request failed to pass verification:\n %@  \nReason: %@",self.request,message);
        NSLog(@"%@",[self description]);
    }
}

-(void)logError:(NSError *)error
{
    if (error)
    {
        [self handleFailureWithReason:[error description]];
    }
}

-(NSString *)description
{
    NSMutableString * expectedValues = [NSMutableString stringWithFormat:@"Expected values:\n"
                                        "HTTPMethod : %@ \n"
                                        "host : %@ \n",self.HTTPMethod,self.host];
    if (self.path && ![self.path isEqualToString:@""])
    {
        [expectedValues appendFormat:@"path : %@ \n",self.path];
    }
    if (self.HTTPHeaderFields)
    {
        [expectedValues appendFormat:@"HTTPHeaderFields : %@ \n",self.HTTPHeaderFields];
    }
    if (self.queryParams)
    {
        [expectedValues appendFormat:@"queryParams : %@ \n",self.queryParams];
    }
    if (self.bodyParams)
    {
        [expectedValues appendFormat:@"bodyParams : %@ \n",self.bodyParams];
    }
    return expectedValues;
}

#pragma mark - serialization

-(NSDictionary *)keyValuePartsFromQuery:(NSString *)query
{
    NSArray * params = [query componentsSeparatedByString:@"&"];
    if (!params)
    {
        return nil;
    }
    
    NSMutableDictionary * receivedParams = [NSMutableDictionary dictionary];
    for (NSString * paramQuery in params)
    {
        NSArray * paramParts = [paramQuery componentsSeparatedByString:@"="];
        
        if ([paramParts count]<2)
        {
            [self handleFailureWithReason:[NSString stringWithFormat:@"query parameter incorrectly formatted: %@",paramQuery]];
            return nil;
        }
        
        receivedParams[paramParts[0]] = [paramParts[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return receivedParams;
}

-(NSString *)queryFromDictionary:(NSDictionary *)queryParts
{
    NSMutableString * string = [NSMutableString string];
    
    for (NSString * key in queryParts)
    {
        [string appendFormat:@"%@=%@",key,queryParts[key]];
    }
    return string;
}

-(id)jsonObjectFromData:(NSData *)data
{
    if (!data)
    {
        return nil;
    }
    NSError * error = nil;
    id serializedObject = [NSJSONSerialization JSONObjectWithData:[self.request HTTPBody]
                                                          options:NSJSONReadingAllowFragments
                                                            error:&error];
    [self logError:error];
    return serializedObject;
}

-(id)plistObjectFromData:(NSData *)data
{
    if (!data)
    {
        return nil;
    }
    NSError * error = nil;
    id serializedObject = [NSPropertyListSerialization propertyListWithData:data
                                                                    options:0
                                                                     format:nil
                                                                      error:&error];
    [self logError:error];
    return serializedObject;
}

-(id)deserializeHTTPBody
{
    switch (self.bodySerializationType) {
        case DTBodySerializationTypeRaw:
        {
            NSString * query = [[NSString alloc] initWithData:self.request.HTTPBody
                                                     encoding:NSUTF8StringEncoding];
            return [self keyValuePartsFromQuery:query];
        }
        case DTBodySerializationTypeJSON:
            return [self jsonObjectFromData:self.request.HTTPBody];
        case DTBodySerializationTypePlist:
            return [self plistObjectFromData:self.request.HTTPBody];
    }
    return nil;
}

#pragma mark - verification

-(BOOL)verifyRequest:(NSURLRequest *)request
{
    self.request = request;
    
    if (![request.HTTPMethod isEqualToString:self.HTTPMethod])
    {
        [self handleFailureWithReason:[NSString stringWithFormat:@"HTTP Method: %@, expected %@",[request HTTPMethod],self.HTTPMethod]];
        return NO;
    }
    
    if (![request.URL.scheme isEqualToString:self.scheme])
    {
        [self handleFailureWithReason:[NSString stringWithFormat:@"Scheme: %@, expected: %@",[request.URL scheme], self.scheme]];
        return NO;
    }
    
    if (![[request.URL host] isEqualToString:self.host])
    {
        [self handleFailureWithReason:[NSString stringWithFormat:@"Request host: %@, expected: %@",[[request URL] host], self.host]];
        return NO;
    }
    
    if (![[request.URL path] isEqualToString:self.path])
    {
        [self handleFailureWithReason:[NSString stringWithFormat:@"Request path: %@, expected: %@",[[request URL] path],self.path]];
        return NO;
    }
    
    if (![self verifyHTTPHeaderFields])
    {
        [self handleFailureWithReason:[NSString stringWithFormat:@"Request HTTP Header fields do not match expected ones"]];
        return NO;
    }
    
    if (![self verifyQueryParams])
    {
        [self handleFailureWithReason:[NSString stringWithFormat:@"Request query params: %@, expected: %@",request.URL.query,[self queryFromDictionary:self.queryParams]]];
        return NO;
    }
    
    if (![self verifyBodyParams])
    {
        return NO;
    }
    
    return YES;
}

-(BOOL)verifyHTTPHeaderFields
{
    for (NSString * key in [self.HTTPHeaderFields allKeys])
    {
        id value = [self.request valueForHTTPHeaderField:key];
        if (![value isEqual:self.HTTPHeaderFields[key]])
        {
            return NO;
        }
    }
    return YES;
}

-(BOOL)verifyQueryParams
{
    NSString * query = [self.request.URL query];
    
    
    NSDictionary * keyValuePairs = [self keyValuePartsFromQuery:query];
    
    if (!keyValuePairs && !self.queryParams)
    {
        return YES;
    }
    return [self verifyParams:self.queryParams
                   withParams:keyValuePairs];
}

-(BOOL)verifyBodyParams
{
    if (![self.request HTTPBody] && (![self.bodyParams count]))
    {
        return YES;
    }
    NSDictionary * params = [self deserializeHTTPBody];
    
    return  [self verifyParams:self.bodyParams
                    withParams:params];
}

-(BOOL)verifyParams:(id)expectedParams
         withParams:(id)receivedParams
{
    BOOL compareResult = NO;
    if ([expectedParams isKindOfClass:[NSArray class]])
    {
        compareResult = [expectedParams isEqualToArray:receivedParams];
    }
    else if ([expectedParams isKindOfClass:[NSDictionary class]])
    {
        compareResult = [expectedParams isEqualToDictionary:receivedParams];
    }
    
    if (!compareResult)
    {
        [self handleFailureWithReason:@"Request body params do not match"];
    }
    return compareResult;
}

@end
