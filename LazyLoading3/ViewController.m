//
//  ViewController.m
//  LazyLoading3
//
//  Created by Quazi Ridwan Hasib on 5/03/2016.
//  Copyright © 2016 Quazi Ridwan Hasib. All rights reserved.
//

#import "ViewController.h"
#import "AppRecord.h"
#import "IconDownloader.h"


@interface ViewController ()<UIScrollViewDelegate>
// the set of IconDownloader objects for each app
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;

@end

@implementation ViewController

NSArray *images ,*titles;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self loadStaticData];
    self.imageDownloadsInProgress = [[NSMutableDictionary alloc] init];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  self.entries .count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    // Reuse and create cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Leave cells empty if there's no data yet
    AppRecord *appRecord = [self.entries objectAtIndex:indexPath.row];
    cell.textLabel.text = appRecord.appName;
    cell.detailTextLabel.text = appRecord.artist;
    
    if (!appRecord.appIcon)
    {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            [self startIconDownload:appRecord forIndexPath:indexPath];
        }
        // if a download is deferred or in progress, return a placeholder image
        cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
    }
    else
    {
        cell.imageView.image = appRecord.appIcon;
    }
    
    
    return cell;
}

#pragma mark - Table cell image support


- (void)startIconDownload:(AppRecord *)appRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.appRecord = appRecord;
        [iconDownloader setCompletionHandler:^{
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            // Display the newly loaded image
            cell.imageView.image = appRecord.appIcon;
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
        }];
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
    }
}

// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have their app icons yet.
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows
{
    if ([self.entries count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            AppRecord *appRecord = [self.entries objectAtIndex:indexPath.row];
            
            if (!appRecord.appIcon)
                // Avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }
        }
    }
}

#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


-(void)loadStaticData{
    titles = [[NSArray alloc]initWithObjects:@"Heads Up! - Warner Bros.",@ "Minecraft – Pocket Edition - Mojang",@ "Blek - Denis Mikan",@ "Afterlight - Simon Filip",@ "Geometry Dash - Robert Topala",@ "Justin.tv - Twitch Interactive, Inc.",@ "Plague Inc. - Ndemic Creations",@ "Bloons TD 5 - Ninja Kiwi",@ "DockStar - Design Home Screen Themes & Wallpapers - Guns & Weapons Video Game Co.",@ "Papa's Freezeria To Go! - Flipline Studios",@ "NOAA Hi-Def Radar - WeatherSphere",@ "The Amazing Spider-Man 2 - Gameloft",@ "THE GAME OF LIFE Classic Edition - Electronic Arts",@ "Facetune - Lightricks Ltd.",@ "Stickman Soccer 2014 - Robert Szeleney",@ "Card Wars - Adventure Time - Cartoon Network",@ "A Dark Room - Amirali Rajan",@ "Buddyman: Kick (by Kick the Buddy) - Crazylion Studios Limited",@ "Videoshop - Video Editor - Joseph Riquelme",@ "7 Minute Workout Challenge - Fitness Guide Inc",@ "Camera+ - tap tap tap",@ "Dark Sky - Weather Radar, Hyperlocal Forecasts, and Storm Alerts - Jackadam",@ "Sleep Cycle alarm clock - Northcube AB",@ "RollerCoaster Tycoon® 4 Mobile™ - Atari",@ "VVVVVV - Terry Cavanagh",@ "Age of Zombies™ - Halfbrick Studios",@ "TETRIS® - Electronic Arts",@ "Sky Guide: View Stars Night or Day - Fifth Star Labs LLC",@ "Angry Birds - Rovio Entertainment Ltd",@ "Scribblenauts Remix - Warner Bros.",@ "MONOPOLY - Electronic Arts",@ "Plants vs. Zombies - PopCap",@ "Ultimate Guitar Tabs - largest catalog of songs with guitar and ukulele chords, tabs and lyrics - Ultimate Guitar",@ "Worms3 - Team17 Software Ltd",@ "Survivalcraft - Igor Kalicinski",@ "Flick Home Run ! - infinity pocket",@ "TurboScan: quickly scan multipage documents into high-quality PDFs - Piksoft Inc.",@ "D&D Lords of Waterdeep - Playdek, Inc.",@ "Terraria - 505 Games (US), Inc.",@ "HotSchedules - HotSchedules",@ "NBA JAM by EA SPORTS™ - Electronic Arts",@ "My Talking Pet - WOBA Media",@ "Infinity Blade III - Chair Entertainment Group, LLC",@ "Pimp Your Screen - Custom Themes, Backgrounds and Wallpapers for iPhone, iPod touch and iPad - Apalon Apps",@ "Angry Birds Star Wars II - Rovio Entertainment Ltd",@ "Akinator the Genie - Elokence",@ "Toca Hair Salon 2 - Toca Boca AB",@ "Doodle Jump - Lima Sky",@ "Grand Theft Auto: San Andreas - Rockstar Games",@ "Spotipremier for Spotify Premium - Rose King",@ "NOAA Radar Pro – Severe Weather Alerts and Forecasts - Apalon Apps",@ "The Impossible Game - FlukeDude Ltd",@ "The Survival Games : Mini Game With Worldwide Multiplayer - wang wei",@ "Fitness Buddy : 1700+ Exercise Workout Journal - Azumio Inc.",@ "Color Status Bar - Custom Top Bar Overlays for Your Wallpapers - Appic Fun",@ "Couch-to-5K - Active Network, LLC",@ "Monument Valley - ustwo™",@ "Papa's Burgeria To Go! - Flipline Studios",@ "App Icons - Apalon Apps",@ "Wipeout - Activision Publishing, Inc.",@ "Kick the Buddy: Second Kick - Crustalli",@ "Agricola - Playdek, Inc.",@ "NBA 2K14 - 2K",@ "Brazil 2014 Radio - World Soccer Radio - JJACR Apps, LLC",@ "Dude Perfect - Dude Perfect",@ "Themes Plus + Pro : The Best Cool & Unique lock and home screen for iPhone iOS 7 - Olinda Porras",@ "Angry Birds Star Wars - Rovio Entertainment Ltd",@ "Full Fitness : Exercise Workout Trainer - Mehrdad Mehrain",@ "MarcoPolo Ocean - MarcoPolo Learning, Inc.",@ "Backflip Madness - Gamesoul Studio",@ "Superimpose - Pankaj Goswami",@ "Pou - Paul Salameh",@ "Multiplayer for Minecraft PE - Innovative Devs",@ "Instant Heart Rate - Heart Rate Monitor by Azumio - Azumio Inc.", @"Instant Blood Pressure - Monitor Blood Pressure Using Only Your iPhone - Aura Labs, Inc.", nil];
    
    images = [[NSArray alloc]initWithObjects:@"http://a764.phobos.apple.com/us/r30/Purple2/v4/8d/05/fe/8d05fecd-ef8e-1393-d7d4-3622078e2b52/mzl.aossebpw.53x53-50.png", @"http://a1592.phobos.apple.com/us/r30/Purple/v4/94/98/2f/94982fe2-4cec-8a02-fbf6-6fe0851276e2/mzl.nlynfkyw.53x53-50.png", @"http://a1356.phobos.apple.com/us/r30/Purple4/v4/35/7d/cc/357dccc3-4cf3-cf86-789d-8ea771138857/mzl.suptdinm.53x53-50.png", @"http://a932.phobos.apple.com/us/r30/Purple6/v4/43/b9/93/43b993fb-05c6-fcfb-bc3f-40c1207ddf0a/mzl.pnmvfolg.53x53-50.png", @"http://a1041.phobos.apple.com/us/r30/Purple4/v4/21/19/13/2119132e-de27-5419-27ff-cd01c017613a/mzl.smhzbsuv.53x53-50.png", @"http://a1628.phobos.apple.com/us/r30/Purple/v4/c9/ce/cf/c9cecfd7-af13-651b-dc2b-d0d22d01e1cd/mzl.vmxpemwk.53x53-50.png", @"http://a1373.phobos.apple.com/us/r30/Purple/v4/d0/0d/c3/d00dc358-309a-820d-9bf5-ea425f3a44bd/mzl.rsuvzsny.53x53-50.png", @"http://a49.phobos.apple.com/us/r30/Purple6/v4/25/d5/66/25d56621-bae4-a789-c433-de4c544fac85/mzl.nxtdlzdt.53x53-50.png", @"http://a1053.phobos.apple.com/us/r30/Purple2/v4/98/6b/62/986b626a-8c95-b2a5-5807-9d1a4eb00abd/mzl.nrbjvjys.53x53-50.png", @"http://a1465.phobos.apple.com/us/r30/Purple/v4/fb/7a/63/fb7a6389-ebde-3d03-2ce6-2334ea8d1cd8/mzl.ukyrpktf.53x53-50.png", @"http://a442.phobos.apple.com/us/r30/Purple/v4/cc/79/07/cc79074d-df84-2097-92c5-2f9c14049169/mzl.xullraer.53x53-50.png", @"http://a1112.phobos.apple.com/us/r30/Purple2/v4/73/a1/b2/73a1b28a-c09a-fd6a-85ce-e2a1a6f84652/mzl.aidxjeag.53x53-50.png", @"http://a1823.phobos.apple.com/us/r30/Purple2/v4/10/76/fd/1076fd87-136b-83a4-69ac-e0725fa726f2/mzl.qwcyuism.53x53-50.png", @"http://a543.phobos.apple.com/us/r30/Purple6/v4/7d/8f/ae/7d8faed6-236b-3238-afaf-140aa52e1de4/mzl.coxuylvs.53x53-50.png", @"http://a1593.phobos.apple.com/us/r30/Purple/v4/e0/6a/ec/e06aec2a-89f8-aa67-eec9-d1c2109d11bf/mzl.vuibxtci.53x53-50.png", @"http://a348.phobos.apple.com/us/r30/Purple4/v4/58/70/c6/5870c61e-a878-9903-196d-b4e334c35e9d/mzl.fxbhzwrj.53x53-50.png", @"http://a158.phobos.apple.com/us/r30/Purple/v4/f2/f1/5e/f2f15e5c-895e-2f94-cf60-becf897166cf/mzl.ypourqju.53x53-50.png", @"http://a1530.phobos.apple.com/us/r30/Purple4/v4/51/30/e7/5130e761-5db2-7f9a-ad41-7a35bffa499f/mzl.bkaywzmk.53x53-50.png", @"http://a1627.phobos.apple.com/us/r30/Purple4/v4/82/e4/70/82e4704e-3b1e-0d3a-30f9-cd3410d196ba/mzl.tuxullxi.53x53-50.png", @"http://a1237.phobos.apple.com/us/r30/Purple4/v4/d9/79/e9/d979e9d7-25ef-206f-cd4d-1f2a55d76fc8/mzl.oyljxfjm.53x53-50.png", @"http://a889.phobos.apple.com/us/r30/Purple/v4/19/d4/98/19d4986a-6528-ab98-1c0b-ac1d4a8e4e47/mzl.gdamjwas.53x53-50.png", @"http://a1183.phobos.apple.com/us/r30/Purple4/v4/d0/22/3f/d0223fe7-8bd0-28fa-65dd-9e059e8b2f27/mzl.wqpvuqfk.53x53-50.png", @"http://a1763.phobos.apple.com/us/r30/Purple4/v4/18/f7/c4/18f7c4d7-8be0-2c55-3389-001d79ff6bc8/mzl.atkfmgta.53x53-50.png", @"http://a1211.phobos.apple.com/us/r30/Purple/v4/c1/0b/0a/c10b0a4e-2fd8-dcd9-86d6-bb988628f15d/mzl.eowstjwz.53x53-50.png", @"http://a1644.phobos.apple.com/us/r30/Purple4/v4/00/9d/95/009d957c-15a1-3e6a-b948-99eb495d1fee/mzl.lplmknpd.53x53-50.png", @"http://a1574.phobos.apple.com/us/r30/Purple/v4/e5/6f/14/e56f144e-4dfe-8553-041c-0ed41a0fbf51/mzl.kjjvbsye.53x53-50.png", @"http://a588.phobos.apple.com/us/r30/Purple/v4/f8/41/17/f84117cc-a5a9-0f8f-1c64-deedcf1f27e4/mzl.uxgzvffn.53x53-50.png", @"http://a513.phobos.apple.com/us/r30/Purple/v4/f9/c7/44/f9c744ab-3156-87a6-880d-56ac6ce25377/mzl.gehkirnd.53x53-50.png", @"http://a1680.phobos.apple.com/us/r30/Purple/v4/fd/dc/91/fddc91e7-c6b2-2552-bf24-d0dce3ef72b6/mzl.onvampds.53x53-50.png", @"http://a63.phobos.apple.com/us/r30/Purple6/v4/f4/42/be/f442be41-1e2c-b389-e4a4-b16ea47909e7/mzl.vvlbbuke.53x53-50.png", @"http://a29.phobos.apple.com/us/r30/Purple6/v4/bf/6c/02/bf6c02d0-9650-d6ae-d19e-1e6eddf55bce/mzl.ogvlqywp.53x53-50.png", @"http://a1392.phobos.apple.com/us/r30/Purple/v4/6b/59/50/6b59500f-0e7b-d93e-ce72-32a13b684b53/mzl.vazwocma.53x53-50.png", @"http://a999.phobos.apple.com/us/r30/Purple6/v4/f1/64/87/f1648707-c069-eb27-2f12-163cb897d2ad/mzl.dqetqqfm.53x53-50.png", @"http://a1416.phobos.apple.com/us/r30/Purple4/v4/2b/37/1a/2b371a4c-d5c6-68ba-030e-da7f4acfe292/mzl.rwvcypcr.53x53-50.png", @"http://a1151.phobos.apple.com/us/r30/Purple/v4/db/88/dd/db88dd11-d983-8cdd-03eb-0908d828b72a/mzl.yaojkuqk.53x53-50.png", @"http://a846.phobos.apple.com/us/r30/Purple4/v4/80/c8/b1/80c8b1bd-c78d-9195-4b19-a42ca53edcbc/mzl.zyrepefg.53x53-50.png", @"http://a1599.phobos.apple.com/us/r30/Purple/v4/59/41/db/5941db05-7448-f52f-f0b9-ec7249e2cf7d/mzl.ptzqaneu.53x53-50.png", @"http://a1129.phobos.apple.com/us/r30/Purple6/v4/97/bd/19/97bd198f-f193-5231-6cba-41dddf80babf/mzl.mgknkcgo.53x53-50.png", @"http://a1146.phobos.apple.com/us/r30/Purple4/v4/3c/3d/dd/3c3ddd55-be3e-d8e1-278e-6652f9747102/mzl.zxptizcl.53x53-50.png", @"http://a195.phobos.apple.com/us/r30/Purple6/v4/7e/73/2b/7e732b6d-cde0-a51d-5566-e46603fb5200/mzl.mlzyekdi.53x53-50.png", @"http://a1094.phobos.apple.com/us/r30/Purple/c0/ad/6f/mzl.isborlrs.53x53-50.png", @"http://a433.phobos.apple.com/us/r30/Purple4/v4/00/8a/ae/008aae34-37be-b222-50de-2bf34e5b4b60/mzl.cibjtxtv.53x53-50.png", @"http://a1600.phobos.apple.com/us/r30/Purple2/v4/08/29/bc/0829bcd3-64f6-a338-73ac-76f8d55b920b/mzl.oghcjydx.53x53-50.png", @"http://a750.phobos.apple.com/us/r30/Purple2/v4/a6/07/a6/a607a618-5fb6-246a-e94a-462bbfa8ca6a/mzl.wfamopmy.53x53-50.png", @"http://a1540.phobos.apple.com/us/r30/Purple4/v4/e3/fa/34/e3fa348c-33dd-f47b-8dae-bbd937f5e784/mzl.orrmzhsu.53x53-50.png", @"http://a1905.phobos.apple.com/us/r30/Purple6/v4/e1/ae/7d/e1ae7da5-0968-e04b-6fd4-eca2cbb6b9c4/mzl.vnquvizn.53x53-50.png", @"http://a1974.phobos.apple.com/us/r30/Purple6/v4/88/31/e4/8831e430-a09a-b25b-67e7-34ff66682c37/mzl.kkuyxkza.53x53-50.png", @"http://a179.phobos.apple.com/us/r30/Purple4/v4/c7/54/ed/c754ed14-6822-11c8-b9c2-1851205ebc96/mzl.minnhcin.53x53-50.png", @"http://a825.phobos.apple.com/us/r30/Purple/v4/c4/fc/75/c4fc7528-8c33-5405-d9b3-652200e906dd/mzl.gbejkzkk.53x53-50.png", @"http://a1496.phobos.apple.com/us/r30/Purple4/v4/38/fa/3a/38fa3ad8-3e04-b066-a28a-f624eab68157/mzl.yzjqozjv.53x53-50.png", @"http://a1890.phobos.apple.com/us/r30/Purple4/v4/ff/36/8d/ff368d16-7211-ab59-8649-3cb588f02c5f/mzl.xxvefyvu.53x53-50.png", @"http://a6.phobos.apple.com/us/r30/Purple/v4/91/60/b6/9160b6fb-0684-9b16-5374-c51e278d8371/mzl.lyyeukym.53x53-50.png", @"http://a1219.phobos.apple.com/us/r30/Purple/v4/e6/88/75/e688753c-61e8-66fe-bba7-47d2b90da5cb/mzl.rzglyrsp.53x53-50.png", @"http://a870.phobos.apple.com/us/r30/Purple/v4/10/3b/a3/103ba304-7595-8ac7-cc1a-a56742a8369e/mzl.brcofjbf.53x53-50.png", @"http://a327.phobos.apple.com/us/r30/Purple4/v4/3c/30/61/3c306142-26d5-c88e-61c9-336fef2bb997/mzl.vatwcsjq.53x53-50.png", @"http://a309.phobos.apple.com/us/r30/Purple/v4/c3/f0/2a/c3f02ad0-4679-be27-0188-8c5df46ef0d7/mzl.qzsmgsnm.53x53-50.png", @"http://a111.phobos.apple.com/us/r30/Purple6/v4/e5/13/99/e51399d1-d069-d1e3-3ef1-d8f1e463056b/mzl.ffrdsnvf.53x53-50.png", @"http://a1517.phobos.apple.com/us/r30/Purple/v4/fe/8c/bb/fe8cbb37-42e3-2f37-9331-c708dd32233d/mzl.otyiydak.53x53-50.png", @"http://a38.phobos.apple.com/us/r30/Purple6/v4/71/68/18/716818f0-9ee2-0e7d-e0d1-2447c444b6cf/mzl.mdhcohfa.53x53-50.png", @"http://a43.phobos.apple.com/us/r30/Purple4/v4/55/43/7d/55437d7d-bba7-1bd0-c862-edd627948796/mzl.wyfpveqk.53x53-50.png", @"http://a1739.phobos.apple.com/us/r30/Purple6/v4/44/db/29/44db29c9-d7cf-a261-75b5-7862957b9398/mzl.gzegzotc.53x53-50.png", @"http://a1366.phobos.apple.com/us/r30/Purple4/v4/2a/2e/13/2a2e130a-35ae-b0bd-c12c-f8c4596c0adb/mzl.pnwcrghj.53x53-50.png", @"http://a1210.phobos.apple.com/us/r30/Purple4/v4/cb/b1/ea/cbb1ea96-7141-8ab6-efab-0b5b30291a13/mzl.kwykyuse.53x53-50.png", @"http://a987.phobos.apple.com/us/r30/Purple6/v4/3e/91/a7/3e91a75f-18de-3e3a-37b9-0ee4d3d24c55/mzl.ofzcyrhr.53x53-50.png", @"http://a12.phobos.apple.com/us/r30/Purple4/v4/0c/da/98/0cda9815-970c-683e-f36a-2a39b313940a/mzl.wlnbfpyi.53x53-50.png", @"http://a1237.phobos.apple.com/us/r30/Purple4/v4/c6/c9/60/c6c960b9-bf52-6e90-8949-854d81915e8b/mzl.jibjdqil.53x53-50.png", @"http://a1885.phobos.apple.com/us/r30/Purple/v4/c7/c9/3c/c7c93c63-27f3-1e14-c814-95929647f924/mzl.dappciye.53x53-50.png", @"http://a860.phobos.apple.com/us/r30/Purple4/v4/f5/68/69/f56869ca-ecc7-b078-2ad9-9dd759a675b7/mzl.kanjtbmh.53x53-50.png", @"http://a1400.phobos.apple.com/us/r30/Purple/v4/d7/1f/ea/d71fea24-b7e9-90bc-2bd0-2b807f7d1d49/mzl.jzjjwiwt.53x53-50.png", @"http://a62.phobos.apple.com/us/r30/Purple2/v4/ca/b6/fe/cab6fe2c-ca57-4448-329a-7ad295d9c0ea/mzl.mhfvnrgv.53x53-50.png", @"http://a1650.phobos.apple.com/us/r30/Purple6/v4/2b/d0/ce/2bd0ce43-7ab8-9650-697f-78eed2a3aae0/mzl.kxczuyve.53x53-50.png", @"http://a1519.phobos.apple.com/us/r30/Purple4/v4/3c/94/ac/3c94ac46-b2e6-de40-3460-83a4257d2b59/mzl.obzmehwl.53x53-50.png", @"http://a1536.phobos.apple.com/us/r30/Purple4/v4/19/c3/2f/19c32f01-5264-c6f5-d072-306f925e484c/mzl.khdfxqey.53x53-50.png", @"http://a12.phobos.apple.com/us/r30/Purple6/v4/ec/04/74/ec047455-f52e-d04a-5104-0d8d2e91e03a/mzl.bhartdaa.53x53-50.png", @"http://a256.phobos.apple.com/us/r30/Purple4/v4/a4/a8/0d/a4a80d4a-da46-c8d6-1268-2709e074e357/mzl.ucwumfbe.53x53-50.png", nil];
    
    //@"http://quaziridwanhasib.com/products/5.jpg"
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for (NSInteger i=0;i<(NSInteger)titles.count;i++) {
        AppRecord *app = [[AppRecord alloc]init];
        app.imageURLString = images[i];
        app.appName = titles[i];
        app.artist = [NSString stringWithFormat:@"%d",i];
        [arr addObject:app];
    }
    self.entries = [[NSArray alloc]initWithArray:arr];
}


@end
