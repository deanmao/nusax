#import <Cocoa/Cocoa.h>
#import <NuSAX/NuSAX.h>

int main (int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  	NSError *parseError = nil;
    NuSAX *streamingParser = [[NuSAX alloc] init];
    id list = [streamingParser parseXML:"<fruits><apple  version=\"2.0\" language=\"english\">blah</apple><orange>foo</orange></fruits>" parseError:&parseError];
    // id list = [streamingParser parseXMLFileAtURL:[NSURL URLWithString:@"http://earthquake.usgs.gov/eqcenter/catalogs/eqs7day-M2.5.xml"]  parseError:&parseError];
    NSLog(@"xml: %@", [list stringValue]);
    
    [pool release];
}
