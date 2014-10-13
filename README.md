#NFJWordmatcher

NFJWordmatcher searches a text for many keywords using  Aho-Corasick algorithm or Regular-expression.

![sample01](https://raw.githubusercontent.com/naokif/NFJWordmacher/master/screenshot01.png)
![sample02](https://raw.githubusercontent.com/naokif/NFJWordmacher/master/screenshot02.png)

##Usage
(see sample Xcode project in ```/Demo```)

####1.Add keywords to the matcher

```objc
- (BOOL)addIndex:(NSString *)string object:(id)object;
- (BOOL)addIndex:(NSString *)string object:(id)object useRegex:(BOOL)useRegex;
```

####2,Call ```-fixIndex``` to make Trie
```objc
- (BOOL)fixIndex;
```

In this sample, each keyword is associated with UIColor object.

```objc
- (NFJWordmatcher *)prepareMatcherWithKeywords:(NSArray *)keywords
{
    NFJWordmatcher *matcher = [[NFJWordmatcher alloc] init];
    for (NSString *str in keywords) {
        [matcher addIndex:str object:[self randomColor]];
    }
    [matcher fixIndex];
    return matcher;
}
```

####3.Invoke matching
You can use follow methods.

```objc
- (void)match:(NSString *)query eachMatchCallback:(void (^)(NSString *word, NSRange range, id object, BOOL *stop))block;
- (void)firstMatch:(NSString *)query firstMatchCallback:(void (^)(NSString *word, NSRange range, id object))block;

```

In this sample, you can get UIColor objects from matched keywords.

```objc
- (void)updateTextAttributes
{
    NSMutableAttributedString *attrStr = [self.textView.attributedText mutableCopy];
    [attrStr removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, attrStr.length)];
    
    if (self.matcher) {
        [self.matcher match:attrStr.string eachMatchCallback:^(NSString *word, NSRange range, id object, BOOL *stop) {
            [attrStr addAttribute:NSBackgroundColorAttributeName value:object range:range];
        }];
    }
    self.textView.attributedText = attrStr;
}
```

##Licence
NFJWordmatcher is available under the MIT license. See the LICENSE file for more info.