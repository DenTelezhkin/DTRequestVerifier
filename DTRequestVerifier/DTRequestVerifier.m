//
//  RequestVerifier.m
//  CommandCenter-iPad
//
//  Created by Denys Telezhkin on 25.09.13.
//  Copyright (c) 2013 MLSDev. All rights reserved.
//

#import "DTRequestVerifier.h"

@interface DTRequestVerifier()
@property (nonatomic, strong) NSURLRequest * request;
@end

@implementation DTRequestVerifier

+(instancetype)verifier
{
    DTRequestVerifier * verifier = [self new];

    verifier.HTTPMethod = @"GET";
    verifier.loggingEnabled = YES;
    verifier.path = @"";
    verifier.bodySerializationType = DTBodySerializationTypeJSON;
    
    return verifier;
}

-(void)logMessage:(NSString *)message
{
    if (self.loggingEnabled)
    {
        NSLog(@"DTRequestVerifier. %@",message);
    }
}

-(void)logError:(NSError *)error
{
    if (error)
    {
        [self logMessage:[error description]];
    }
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
            [self logMessage:[NSString stringWithFormat:@"query parameter incorrectly formatted: %@",paramQuery]];
            return nil;
        }
        
        receivedParams[paramParts[0]] = [paramParts[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return receivedParams;
}


-(id)jsonObjectFromData:(NSData *)data
{
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
        [self logMessage:[NSString stringWithFormat:@"HTTP Method for request: %@ does not match expected value: %@",request,self.HTTPMethod]];
        return NO;
    }
    
    if (![[request.URL host] isEqualToString:self.host])
    {
        [self logMessage:[NSString stringWithFormat:@"Request host: %@ does not match expected value : %@",[[request URL] host],self.host]];
        return NO;
    }
    
    if (![[request.URL path] isEqualToString:self.path])
    {
        [self logMessage:[NSString stringWithFormat:@"Request path: %@ does not match expected value : %@",[[request URL] path],self.path]];
        return NO;
    }
    
    if (![self verifyHTTPHeaderFields])
    {
        [self logMessage:[NSString stringWithFormat:@"Request HTTP Header fields: %@ do not match expected HTTP Header fields : %@",[request allHTTPHeaderFields],self.HTTPHeaderFields]];
        return NO;
    }
    
    if (![self verifyQueryParams])
    {
        [self logMessage:[NSString stringWithFormat:@"Request query params: %@ do not match expected params : %@",request,self.queryParams]];
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
    
    if (!compareResult && self.loggingEnabled)
    {
        NSLog(@"Request expected body params: %@ do not match received params: %@",expectedParams,receivedParams);
    }
    return compareResult;
}

@end
