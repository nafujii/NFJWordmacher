//
//  ViewController.m
//  NFJWordmacher
//
//  Created by Naoki Fujii on 2014/10/13.
//  Copyright (c) 2014年 nfujii. All rights reserved.
//

#import "ViewController.h"
#import "NFJWordmatcher.h"
@interface ViewController () <UISearchBarDelegate>
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) NFJWordmatcher *matcher;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toggleBtn;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation ViewController {
    NSString *_jpDummy;
    NSString *_enDummy;
    BOOL _dummyIsEng;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.showsCancelButton = YES;
    searchBar.delegate = self;
    self.searchBar = searchBar;
    self.navigationItem.titleView = searchBar;
    
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:[self jpDummy]];
    [self updateToggleButton];
}

#pragma mark - Invoke matching
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

#pragma mark - Set up a matcher
- (NFJWordmatcher *)prepareMatcherWithKeywords:(NSArray *)keywords
{
    NFJWordmatcher *matcher = [[NFJWordmatcher alloc] init];
    for (NSString *str in keywords) {
        [matcher addIndex:str object:[self randomColor]];
    }
    [matcher fixIndex];
    return matcher;
}

- (UIColor *)randomColor
{
    // https://gist.github.com/kylefox/1689973
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

#pragma mark - Change text language and Prepare dummy text
- (void)updateToggleButton
{
    if (_dummyIsEng) {
        self.toggleBtn.title = @"change text to Japanese";
    } else {
        self.toggleBtn.title = @"change text to English";
    }
}

- (IBAction)toggleText:(id)sender
{
    if (_dummyIsEng) {
        self.textView.attributedText = [[NSAttributedString alloc] initWithString:[self jpDummy]];
    } else {
        self.textView.attributedText = [[NSAttributedString alloc] initWithString:[self enDummy]];
    }
    _dummyIsEng = !_dummyIsEng;
    [self updateToggleButton];
}

- (NSString *)jpDummy
{
    if (!_jpDummy) {
        _jpDummy = [self dummyStringWithName:@"jpDummy"];
    }
    return _jpDummy;
}

- (NSString *)enDummy
{
    if (!_enDummy) {
        _enDummy = [self dummyStringWithName:@"enDummy"];
    }
    return _enDummy;
}

- (NSString *)dummyStringWithName:(NSString *)fileName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    if (path) {
        return [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    }
    return nil;
}


#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    self.matcher = nil;
    [self updateTextAttributes];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];

    NSString *str = searchBar.text;
    NSArray *keywords = [str componentsSeparatedByString:@" "];
    if (0 < keywords.count) {
        self.matcher = [self prepareMatcherWithKeywords:keywords];
    } else {
        self.matcher = nil;
    }
    [self updateTextAttributes];
}

@end
