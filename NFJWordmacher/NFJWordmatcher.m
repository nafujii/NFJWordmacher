//
//  NFJWordmatcher.m
//  NFJWordmacher
//
//  Created by fujioki on 2013/08/12.
//  Copyright (c) 2013 fujioki. All rights reserved.
//

#import "NFJWordmatcher.h"

@interface NFJTrieState : NSObject
@property (nonatomic) NSMutableDictionary *next;
@property (nonatomic) NSNumber            *ID;

- (id)initWithID:(NSNumber *)ID;
- (BOOL)hasKey:(id)key;
@end

@implementation NFJTrieState
- (id)initWithID:(NSNumber *)ID
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _next = [[NSMutableDictionary alloc] init];
    _ID   = ID;
    return self;
}
- (BOOL)hasKey:(id)key
{
    if (self.next[key]) {
        return YES;
    }
    return NO;
}
@end

static NSString *const kTermKey = @"term";
static NSString *const kObjectKey = @"object";

@interface NFJWordmatcher ()
@property (nonatomic) NSMutableArray      *output;
@property (nonatomic) NSMutableArray      *state;
@property (nonatomic) NSArray             *failure;
@property (nonatomic) NSMutableArray      *termsWithObjects;
@property (nonatomic) NSMutableDictionary *regexTermsWithObjects;
@property (nonatomic) NSRegularExpression *regex;
@end

@implementation NFJWordmatcher {
    BOOL _indexWasFixed;
    
}

#pragma mark - Initialize
- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _termsWithObjects      = [[NSMutableArray alloc] init];
    _regexTermsWithObjects = [[NSMutableDictionary alloc] init];
    _output    = [[NSMutableArray alloc] init];
    _output[0] = [[NSMutableArray alloc] init];
    _state     = [[NSMutableArray alloc] init];
    _state[0]  = [[NFJTrieState alloc] initWithID:@0];

    return self;
}

#pragma mark - Make Trie
- (BOOL)addIndex:(NSString *)string object:(id)object
{
    return [self addIndex:string object:object useRegex:NO];
}

- (BOOL)addIndex:(NSString *)string object:(id)object useRegex:(BOOL)useRegex
{
    if (_indexWasFixed) {
        return NO;
    }
    
    if (![string isKindOfClass:[NSString class]]) {
        NSLog(@"[%s]error : aString is not NSString object.", __FUNCTION__);
        return NO;
    }
    
    if (useRegex) {
        self.regexTermsWithObjects[string] = object?:[NSNull null];
    }
    else {
        [self.termsWithObjects addObject:@{
                                           kTermKey   : string,
                                           kObjectKey : object?:[NSNull null],
                                           }];
    }
    return YES;
}

- (BOOL)fixIndex
{
    if (_indexWasFixed) {
        return NO;
    }

    // Aho-Corasick
    [self p_makeGoto];
    [self p_makeFailure];

    // Regex
    NSString *pattern = [self p_makeRegexPattern];

    return _indexWasFixed = YES && [self p_makeRegex:pattern];
}


#pragma mark - Regular-expression
- (BOOL)p_makeRegex:(NSString *)pattern
{
    if (0 < pattern.length) {
        NSError *error = nil;
        self.regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAnchorsMatchLines error:&error];
        if (error) {
            NSLog(@"%s error : %@",__FUNCTION__, error);
            return NO;
        }
    }
    return YES;
}

- (NSString *)p_makeRegexPattern
{
    NSDictionary *regexTermsWithObjects = self.regexTermsWithObjects;
    NSMutableString *pattern = [[NSMutableString alloc] init];
    for (NSString *key in regexTermsWithObjects.allKeys) {
        [pattern appendFormat:@"(?:%@)|",key];
    }
    // remove last "|"
    if (regexTermsWithObjects.count > 0) {
        [pattern deleteCharactersInRange:NSMakeRange(pattern.length-1,1)];
    }
    return pattern;
}


#pragma mark - Aho-Corasick algorithm
- (void)p_makeGoto
{
    NSArray *termsWithObjects = self.termsWithObjects;
    for (NSDictionary *termWithObject in termsWithObjects) {
        NFJTrieState *current = self.state[0];
        NSString *term = termWithObject[@"term"];
        NSInteger length = term.length;
        for (int i = 0; i < length; i++) {
            NSString *x = [term substringWithRange:NSMakeRange(i, 1)];
            if (![current hasKey:x]) {
                NFJTrieState *new = [[NFJTrieState alloc] initWithID:[NSNumber numberWithInteger:self.state.count]];
                current.next[x] = new;
                [self.state addObject:new];
                [self.output addObject:[[NSMutableArray alloc] init]];
            }
            current = current.next[x];
            
        }
        NSNumber *s = current.ID;
        NSMutableArray *outputArray = self.output[s.integerValue];
        [outputArray addObject:termWithObject];
    }
    
}

- (void)p_makeFailure
{
    NSMutableArray *failure = [[NSMutableArray alloc] init];
    NSInteger length = self.state.count;
    for (int i = 0; i < length; i++) {
        failure[i] = @0;
    }
    
    NSMutableArray *queue = [[NSMutableArray alloc] init];
    queue[0] = @0;
    while (queue.count > 0) {
        NSNumber *s = [queue firstObject];
        [queue removeObjectAtIndex:0];
        
        NFJTrieState *state = self.state[s.integerValue];
        for (NSString *x in state.next.allKeys) {
            NSNumber *next = [self p_gotoForID:s searchingKey:x];
            if (next) {
                [queue addObject:next];
            }
            if (![s isEqualToNumber:@0]) {
                NSNumber *f = failure[s.integerValue];
                while (![self p_gotoForID:f searchingKey:x]) {
                    f = failure[f.integerValue];
                }
                failure[next.integerValue]  = [self p_gotoForID:f searchingKey:x];
                NSMutableArray *outputArray = self.output[next.integerValue];
                NSNumber *index = failure[next.integerValue];
                [outputArray addObjectsFromArray:self.output[index.integerValue]];
            }
            
        }
    }
    
    self.failure = failure;
}

- (NSNumber *)p_gotoForID:(NSNumber *)currentID searchingKey:(NSString *)key
{
    NFJTrieState *state = self.state[currentID.integerValue];
    if (state.next[key]) {
        return ((NFJTrieState *)state.next[key]).ID;
    } else {
        if ([currentID isEqualToNumber:@0]) {
            return @0;
        } else {
            return nil;
        }
    }
}


#pragma mark - Search keywords
- (void)match:(NSString *)query eachMatchCallback:(void (^)(NSString *word, NSRange range, id object, BOOL *stop))block
{
    /* prepare for regex */
    NSTextCheckingResult *match = nil;
    NSRange               range = NSMakeRange(0, 0);

    NSArray   *matches   = nil;
    NSInteger matchCount = 0;
    NSInteger index      = 0;
    if (self.regex) {
        matches = [self.regex matchesInString:query options:0 range:NSMakeRange(0, query.length)];
        matchCount = matches.count;
        
        if (matchCount > 0) {
            match = matches[index++];
            range = [match rangeAtIndex:0];
        }
    }
    
    
    NSNumber *s = @0;
    NSInteger  length = query.length;
    for (int i = 0; i < length; i++) {
        
        /* Regex output start */
        if (match && i == NSMaxRange(range)-1) {
            NSString *x = [query substringWithRange:[match rangeAtIndex:0]];
            
            // specify a mached word from added regex keywords
            NSString *key = [self p_keyForMachingString:x];
            if (key) {
                id object = self.regexTermsWithObjects[key];
                BOOL stop = NO;
                
                block(x, range, object, &stop);
                if (stop) return;
            }
            //　Prepare next
            match = index < matchCount?matches[index++]:nil;
        }
        /* Regex output end */
        
        
        /* Aho-Corasick output start */
        while ([self p_gotoForID:s searchingKey:[query substringWithRange:NSMakeRange(i, 1)]] == nil)  {
            s = self.failure[s.integerValue];
        }
        s = [self p_gotoForID:s searchingKey:[query substringWithRange:NSMakeRange(i, 1)]];
        for (NSDictionary *termWithObject in self.output[s.integerValue]) {
            NSString *x = termWithObject[kTermKey];
            NSInteger location = i-x.length+1;

            BOOL stop = NO;
            block(x, NSMakeRange(location,i-location+1),termWithObject[kObjectKey], &stop);
            if (stop) return;
        }
        /* Aho-Corasick output end */
    }
}

- (void)firstMatch:(NSString *)query firstMatchCallback:(void (^)(NSString *word, NSRange range, id object))block
{
    [self match:query eachMatchCallback:^(NSString *word, NSRange range, id object, BOOL *stop) {
        block(word, range, object);
        *stop = YES;
    }];
}

/*
   Specify a mached word from added regex keywords. This method has a performance issue.
 */
- (NSString *)p_keyForMachingString:(NSString *)string
{
    NSRange range = NSMakeRange(0, string.length);
    for (NSString *key in self.regexTermsWithObjects.allKeys) {
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:key options:NSRegularExpressionAnchorsMatchLines error:&error];
        
        if (!regex) {
            NSLog(@"%@:%@", [error localizedDescription], [error localizedFailureReason]);
            continue;
        }
        
        NSInteger matchNum = [regex numberOfMatchesInString:string options:0 range:range];
        if (matchNum>0) {
            return key;
        }
    }
    return nil;
}
@end
