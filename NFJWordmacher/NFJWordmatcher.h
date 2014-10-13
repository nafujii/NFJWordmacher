
//
//  Created by fujioki on 2013/08/12.
//  Copyright (c) 2013 fujioki. All rights reserved.
//
//  References
//  http://d.hatena.ne.jp/naoya/20090405/aho_corasick

#import <Foundation/Foundation.h>

/*
 NFJWordmatcher searches words in text using Aho-Corasick algorithm or Regular-expression.
 */
@interface NFJWordmatcher : NSObject

/**
 *  Add a keyword to the matcher. If you use a keywrod that is regex, use "-addIndex:object:useRegex:".
 *
 *  @param string  a keyword that you want search for in the text
 *  @param object You can asociate an object with the keyword. This is option.
 *
 *  @return If the operation is successful, return YES. After calling "-fixIndex", the oparation will fail and return NO.
 */
- (BOOL)addIndex:(NSString *)string object:(id)object;

/**
 *  Add a keyword to the matcher.
 *
 *  @param string  a keyword that you want search for in the text
 *  @param object You can asociate an object with the keyword. This is option.
 *  @param useRegex if the keyword is regex, enter YES.
 *
 *  @return If the operation is successful, return YES. After calling "-fixIndex", the oparation will fail and return NO.
 */
- (BOOL)addIndex:(NSString *)string object:(id)object useRegex:(BOOL)useRegex;

/**
 *  Make Trie. You can not add keywords after calling this.
 *
 *  @return If the operation is successful, return YES.
 */
- (BOOL)fixIndex;

/**
 *  Search keywords in a query.
 *
 *  @param query A text that you want to search.
 *  @param block A block will be invoked every time the matcher finds a keyword.
 */
- (void)match:(NSString *)query eachMatchCallback:(void (^)(NSString *word, NSRange range, id object, BOOL *stop))block;

/**
 *  Search keywords in a query.
 *
 *  @param query A text that you want to search.
 *  @param block A block will be invoked when the matcher finds a keyword first.
 */
- (void)firstMatch:(NSString *)query firstMatchCallback:(void (^)(NSString *word, NSRange range, id object))block;
@end
