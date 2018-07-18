/*
 * Copyright (C) 2017 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#import "TWTRAuthConfig.h"

@interface TWTRAuthConfig () <NSCoding>

@property (nonatomic, copy, readwrite) NSString *consumerKey;
@property (nonatomic, copy, readwrite) NSString *consumerSecret;
@property (nonatomic, copy, readwrite, nullable) NSString *urlSchemeSuffix;

@end

@implementation TWTRAuthConfig

- (instancetype)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret
{
    return [self initWithConsumerKey:consumerKey consumerSecret:consumerSecret urlSchemeSuffix:nil];
}

- (instancetype)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret urlSchemeSuffix:(nullable NSString *)urlSchemeSuffix
{
    NSParameterAssert(consumerKey);
    NSParameterAssert(consumerSecret);
    if ((self = [super init])) {
        _consumerKey = [consumerKey copy];
        _consumerSecret = [consumerSecret copy];
        _urlSchemeSuffix = [urlSchemeSuffix copy];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    NSString *key = [coder decodeObjectForKey:@"consumerKey"];
    NSString *secret = [coder decodeObjectForKey:@"consumerSecret"];
    NSString *urlSchemeSuffix = [coder decodeObjectForKey:@"urlSchemeSuffix"];

    return [self initWithConsumerKey:key consumerSecret:secret urlSchemeSuffix:urlSchemeSuffix];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.consumerKey forKey:@"consumerKey"];
    [coder encodeObject:self.consumerSecret forKey:@"consumerSecret"];
    [coder encodeObject:self.urlSchemeSuffix forKey:@"urlSchemeSuffix"];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[TWTRAuthConfig class]]) {
        return [self isEqualToAuthConfig:object];
    }
    return NO;
}

- (BOOL)isEqualToAuthConfig:(TWTRAuthConfig *)otherAuthConfig
{
    if (self.urlSchemeSuffix == nil && otherAuthConfig.urlSchemeSuffix == nil) {
        return [self.consumerKey isEqualToString:otherAuthConfig.consumerKey]
        && [self.consumerSecret isEqualToString:otherAuthConfig.consumerSecret];
    } else {
        return [self.urlSchemeSuffix isEqualToString:otherAuthConfig.urlSchemeSuffix]
        && [self.consumerKey isEqualToString:otherAuthConfig.consumerKey]
        && [self.consumerSecret isEqualToString:otherAuthConfig.consumerSecret];
    }
}

- (NSUInteger)hash
{
    return [self.consumerKey hash];
}

@end
