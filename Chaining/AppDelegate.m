//
//  AppDelegate.m
//  Chaining
//
//  Created by Wendy Lu on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate {
    ViewController *vc;
    UIBackgroundTaskIdentifier _bgTask;
    CLLocationManager *_locationManager;
}

@synthesize window = _window;

- (void) reUpBGTask {
    UIBackgroundTaskIdentifier tempbgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        if (_bgTask != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
        }
        _bgTask = UIBackgroundTaskInvalid;
    }];
    
    if (_bgTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:_bgTask];
        _bgTask = UIBackgroundTaskInvalid;
    }
    _bgTask = tempbgTask;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.distanceFilter = 100;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _locationManager.delegate = self;
    
    //ask for permission
    [_locationManager startUpdatingLocation];
    [_locationManager stopUpdatingLocation];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self logPath]]) {
        [[NSFileManager defaultManager] createFileAtPath:[self logPath] contents:nil attributes:nil];
    }

    vc = [[ViewController alloc] init];
    self.window.rootViewController = vc;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (NSString *) logPath;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *filePath = [NSString stringWithFormat:@"%@/log.txt", [paths objectAtIndex:0]];
    return filePath;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self reUpBGTask];
    double this_delay_time = [[UIApplication sharedApplication] backgroundTimeRemaining] - 10.0;
    
    [self startUpdateAfterDelay:this_delay_time];
}

- (void)startUpdateAfterDelay:(float)seconds {
    if (seconds > 10000) { //in foreground
        seconds = 590.0;
    }
    double this_delay_time = seconds;
    
    //start updates
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, this_delay_time * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [_locationManager startUpdatingLocation];
        NSString *log = [NSString stringWithFormat:@"start updating BGTime: %f", [[UIApplication sharedApplication] backgroundTimeRemaining]];
        NSLog(@"%@", log);
        [self append:log];
    });
    
    //stop updates
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (this_delay_time + 10.0) * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        [_locationManager stopUpdatingLocation];
        NSString *log = [NSString stringWithFormat:@"stop updating BGTime: %f", [[UIApplication sharedApplication] backgroundTimeRemaining]];
        NSLog(@"%@", log);
        [self append:log];
    });
    
    //wait 5 seconds and dispatch this method again
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (this_delay_time + 15.0) * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        float delayTime = [[UIApplication sharedApplication] backgroundTimeRemaining] - 10.0;
        [self startUpdateAfterDelay:delayTime];
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    vc = [[ViewController alloc] init];
    self.window.rootViewController = vc;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSString *log = [NSString stringWithFormat:@"Got update Coord: %f, %f BGTime: %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude,[[UIApplication sharedApplication] backgroundTimeRemaining]];
    NSLog(@"%@", log);
    [self append:log];
}

-(NSString*)logString;
{
    NSString * str = [NSString stringWithContentsOfFile:[self logPath] encoding:NSUTF8StringEncoding error:nil];
    return str;
}

- (void)append:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    
    NSString * log = [NSString stringWithFormat:@"%@	%@ App State: %d\n\n", [dateFormatter stringFromDate:[NSDate date]],string, [[UIApplication sharedApplication] applicationState]];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:[self logPath]];
    [fileHandle seekToEndOfFile];
    
    [fileHandle writeData:[log dataUsingEncoding:NSUTF8StringEncoding]];
    
    [fileHandle closeFile];
    
    [vc reload];
}

@end
