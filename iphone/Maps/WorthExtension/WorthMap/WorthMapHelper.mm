#import "WorthMapHelper.h"
#import "MapsAppDelegate.h"
#import "MapViewController.h"
#import "MWMRouter.h"
#import "MWMRoutePoint+CPP.h"
#import "MWMCoreRouterType.h"
#import "MWMMapViewControlsManager.h"
#import "MWMFrameworkListener.h"

#include <CoreApi/Framework.h>
#include "geometry/mercator.hpp"
#include "drape_frontend/visual_params.hpp"
#include "map/gps_track.hpp"
#include "platform/local_country_file_utils.hpp"

using platform::LocalCountryFile;
using namespace platform;
using namespace std;
using namespace url_scheme;

@implementation WorthMapHelper

+ (void)handleNavigatorUrl:(NSURL *)url {
  NSLog(@"Navigator : %@", url);

  NSString *query = [url query];
  NSArray *queryComponents = [query componentsSeparatedByString:@"&"];
  if (queryComponents.count < 4) {
    NSLog(@"Invalid query string.");
    return;
  }

  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  for (NSString *component in queryComponents) {
    NSArray *pair = [component componentsSeparatedByString:@"="];
    if (pair.count == 2) {
      NSString *key = pair[0];
      NSString *value = [pair[1] stringByRemovingPercentEncoding];
      params[key] = value;
    }
  }

  double lat = [params[@"lat"] doubleValue];
  double lon = [params[@"lon"] doubleValue];
  NSString *name = params[@"name"] ?: @"Destination";
  NSString *desc = params[@"desc"] ?: @"";

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

    m2::PointD point = mercator::FromLatLon(lat, lon);
    
    MWMRoutePoint *destinationPoint = [[MWMRoutePoint alloc] initWithPoint:point
                                                                      title:name
                                                                   subtitle:desc
                                                                       type:MWMRoutePointTypeFinish
                                                          intermediateIndex:0];
    [MWMRouter buildToPoint:destinationPoint bestRouter:YES];

    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.worth"];
    [userDefaults setBool:YES forKey:@"started_from_worth"];
  });
}

+ (void)registerMaps {
  Framework &f = GetFramework();
  f.DeregisterAllMaps();
  f.RegisterAllMaps();
}

+ (void)loadManager {
  GetFramework().GetPowerManager().Load();
}

@end
