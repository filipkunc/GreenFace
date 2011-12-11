//
//  GFWebLevelsViewController.m
//  GreenFace
//
//  Created by Filip Kunc on 12/5/11.
//  Copyright (c) 2011 Filip Kunc. All rights reserved.
//

#import "GFWebLevelsViewController.h"

NSString *webServerName = @"http://greenface.heroku.com";

@implementation GFWebLevelsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        levels = [[NSMutableArray alloc] init];
        
        [[self navigationItem] setTitle:@"Web levels"];
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setColor:[UIColor colorWithWhite:0.0f alpha:1.0f]];
    }
    return self;
}

- (void)loadLevels
{
    [levels removeAllObjects];
    //[[self tableView] reloadData];
    [[self tableView] setHidden:YES];
    
    UIView *superView = [[self tableView] superview];
    
    [activityIndicator setCenter:[superView center]];
    [activityIndicator startAnimating];
    [superView addSubview:activityIndicator];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/levels.xml", webServerName]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    if (connection)
        [connection cancel];
    
    xmlData = [[NSMutableData alloc] init];
    downloadingLevel = NO;
    
    connection = [[NSURLConnection alloc] initWithRequest:request 
                                                 delegate:self
                                         startImmediately:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadLevels];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [xmlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (downloadingLevel)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *levelPath = [documentsDirectory stringByAppendingPathComponent:levelName];
        [xmlData writeToFile:levelPath atomically:YES];
        [downloadingButton setTitle:@"Downloaded" forState:UIControlStateNormal];
        [downloadingButton setFrame:CGRectMake(0, 0, 110, 30)];
    }
    else
    {
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:xmlData];
        [xmlParser setDelegate:self];
        [xmlParser parse];        
        [[self tableView] reloadData];
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];
        [[self tableView] setHidden:NO];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    currentElementName = elementName;
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
    currentElementName = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ([currentElementName isEqualToString:@"title"])
        [levels addObject:[string copy]];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [levels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LevelCell"];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LevelCell"];
        
        UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [downloadButton setTitle:@"Download" forState:UIControlStateNormal];
        [downloadButton setFrame:CGRectMake(0, 0, 100, 30)];
        [downloadButton addTarget:self action:@selector(buttonPressed:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [cell setAccessoryView:downloadButton];
    }
    
    [[cell textLabel] setText:[levels objectAtIndex:[indexPath row]]];
    
    return cell;
}

- (void)buttonPressed:(id)sender withEvent:(UIEvent *)event
{
    downloadingButton = (UIButton *)sender;
    [downloadingButton setTitle:@"Downloading" forState:UIControlStateNormal];
    [downloadingButton setFrame:CGRectMake(0, 0, 120, 30)];
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    levelName = [NSString stringWithFormat:@"%@.greenlevel", [levels objectAtIndex:[indexPath row]]];
    NSString *urlString = [NSString stringWithFormat:@"%@/Levels/%@.xml", webServerName, [levels objectAtIndex:[indexPath row]]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30];
    if (connection)
        [connection cancel];
    
    xmlData = [[NSMutableData alloc] init];
    downloadingLevel = YES;
    
    connection = [[NSURLConnection alloc] initWithRequest:request 
                                                 delegate:self
                                         startImmediately:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
//    GFGameViewController *nextViewController = [[GFGameViewController alloc] init];
//    // Configure the new view controller.
//    [nextViewController setLevelName:[levels objectAtIndex:[indexPath row]]];
//    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    [self.navigationController pushViewController:nextViewController animated:YES];
}

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
