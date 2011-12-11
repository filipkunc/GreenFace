//
//  GFLevelsViewController.m
//  GreenFace
//
//  Created by Filip Kunc on 12/4/11.
//  Copyright (c) 2011 Filip Kunc. All rights reserved.
//

#import "GFLevelsViewController.h"
#import "GFLevelName.h"
#import "GFGameViewController.h"
#import "GFWebLevelsViewController.h"

NSArray *GetLevelsInDocumentDirectory(void);

NSArray *GetLevelsInDocumentDirectory(void)
{
	// Get list of document directories in sandbox
	NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                       NSUserDomainMask, YES);
	
	// Get one and only document directory from that list
	NSString *documentDirectory = [documentDirectories objectAtIndex:0];
	
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentDirectory error:nil];
	
	if (files == nil)
		return nil;
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF ENDSWITH 'greenlevel'"];
	files = [files filteredArrayUsingPredicate:predicate];
    
	NSMutableArray *fullPaths = [[NSMutableArray alloc] init];
    for (NSString *file in files)
		[fullPaths addObject:[[GFLevelName alloc] initWithPath:[documentDirectory stringByAppendingPathComponent:file]]];
	
	return fullPaths;
}

@implementation GFLevelsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        bundledLevels = [[NSArray alloc] initWithObjects:
                         [[GFLevelName alloc] initWithName:@"Tutorial"], 
                         [[GFLevelName alloc] initWithName:@"Jump"], 
                         [[GFLevelName alloc] initWithName:@"Puzzle"], 
                         nil];
        
        downloadedLevels = GetLevelsInDocumentDirectory();
        
        UIBarButtonItem *downloadButton = [[UIBarButtonItem alloc] initWithTitle:@"More levels" 
                                                                           style:UIBarButtonItemStylePlain 
                                                                          target:self
                                                                          action:@selector(showMoreLevels)];
        
        [[self navigationItem] setTitle:@"Levels"];
        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
        [[self navigationItem] setRightBarButtonItem:downloadButton];
    }
    return self;
}
         
- (void)showMoreLevels
{
    GFWebLevelsViewController *nextViewController = [[GFWebLevelsViewController alloc] init];
    [self.navigationController pushViewController:nextViewController animated:YES];
}
         
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Bundled";
    
    if (section == 1)
        return @"Downloaded";
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [bundledLevels count];

    if (section == 1)
        return [downloadedLevels count];
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LevelCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LevelCell"];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    GFLevelName *levelName;
    
    if (indexPath.section == 0)
        levelName = [bundledLevels objectAtIndex:[indexPath row]];
    else
        levelName = [downloadedLevels objectAtIndex:[indexPath row]];    

    [[cell textLabel] setText:[levelName description]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    GFGameViewController *nextViewController = [[GFGameViewController alloc] init];
    // Configure the new view controller.
    
    if (indexPath.section == 0)
        [nextViewController setLevelName:[bundledLevels objectAtIndex:[indexPath row]]];
    else
        [nextViewController setLevelName:[downloadedLevels objectAtIndex:[indexPath row]]];

    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    downloadedLevels = GetLevelsInDocumentDirectory();
    [self.tableView reloadData];
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
