Trackr
=============

An iOS app that tracks a user's location continuously, and logs the location around every 100 meters of change. 

Functional when the app is in the foreground or background. Built in 2012 for iOS6. Logs are written out to log.txt.

## Get Started

```
git clone git@github.com:wendylu/Trackr.git
```

## Requirements

Trackr requires iOS 5.1 or higher and ARC

## About This Project

**Experiment**: 

Track a user's location continuously without being terminated by the OS. Written during iOS6, when apps ran for ~10 minutes of background time after being backgrounded. The goal is to compare the battery usage of this solution vs other location-tracking solutions, such as [Geofencing](https://github.com/wendylu/Geofence)

**Proposed Scheme:**

Upon backgrounding, checks the background time remaining and calls startUpdatingLocation 10 seconds before the background time expires. 10 seconds later (at 0 seconds of background time), calls stopUpdatingLocation. We now have a new 10 minutes of background time.