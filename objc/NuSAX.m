/*
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#import "NuSAX.h"
#import <Nu/Nu.h>
#import "XMLUtilities.h"

void NuSAXInit()
{
    static initialized = 0;
    if (!initialized) {
        initialized = 1;
        [Nu loadNuFile:@"nusax" fromBundleWithIdentifier:@"nu.programming.nusax" withContext:nil];
    }
}

@interface NuSAX()

static void startDocumentSAX (void * ctx);
static void endDocumentSAX (void * ctx);
static void startElementSAX (void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes);
static void	endElementSAX (void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI);
static void	charactersFoundSAX	(void * ctx, const xmlChar * ch, int len);
static void errorEncounteredSAX (void * ctx, const char * msg, ...);
static void fatalErrorEncounteredSAX (void * ctx, const char * msg, ...);

@end

static xmlSAXHandler simpleSAXHandlerStruct = {
    NULL,                       /* internalSubset */
    NULL,                       /* isStandalone   */
    NULL,                       /* hasInternalSubset */
    NULL,                       /* hasExternalSubset */
    NULL,                       /* resolveEntity */
    NULL,                       /* getEntity */
    NULL,                       /* entityDecl */
    NULL,                       /* notationDecl */
    NULL,                       /* attributeDecl */
    NULL,                       /* elementDecl */
    NULL,                       /* unparsedEntityDecl */
    NULL,                       /* setDocumentLocator */
    startDocumentSAX,           /* startDocument */
    endDocumentSAX,             /* endDocument */
    NULL,                       /* startElement*/
    NULL,                       /* endElement */
    NULL,                       /* reference */
    charactersFoundSAX,         /* characters */
    NULL,                       /* ignorableWhitespace */
    NULL,                       /* processingInstruction */
    NULL,                       /* comment */
    NULL,                       /* warning */
    errorEncounteredSAX,        /* error */
    fatalErrorEncounteredSAX,   /* fatalError //: unused error() get all the errors */
    NULL,                       /* getParameterEntity */
    NULL,                       /* cdataBlock */
    NULL,                       /* externalSubset */
    XML_SAX2_MAGIC,             //
    NULL,
    startElementSAX,            /* startElementNs */
    endElementSAX,              /* endElementNs */
    NULL,                       /* serror */
};

static xmlSAXHandler *simpleSAXHandler = &simpleSAXHandlerStruct;

@implementation NuSAX

@synthesize processed = _processed;

+ (void) load
{
   NuSAXInit();
}

- (id) parseXML:(const char *)XMLString parseError:(NSError **)parseError {
  if (!XMLString) {
    return _nunull();
  }
  self.processed = [[NSMutableArray alloc] initWithCapacity: 1];

  xmlParserCtxtPtr ctxt = xmlCreateDocParserCtxt((xmlChar*)XMLString);

  int parseResult = xmlSAXUserParseMemory(simpleSAXHandler, self, XMLString, strlen(XMLString));

  if (parseResult != 0 && parseError) {
    *parseError = [NSError errorWithDomain:XMLParsingErrorDomainString code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Parsing failed", NSLocalizedFailureReasonErrorKey, nil]]; 
  } else {
    return [self.processed lastObject];
  }

  xmlFreeParserCtxt(ctxt);
  xmlCleanupParser();
  xmlMemoryDump();
}

- (id) parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error {
    NSError *err = nil;
    NSString *URLContents = [NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:&err];
    
    if (!URLContents) {
      return _nunull();
    }
        
    return [self parseXML:[URLContents UTF8String] parseError:error];
}

static NSString *
getQualifiedName (const xmlChar *prefix, const xmlChar *localName)
{
  if (!prefix || !localName) {
    return nil;
  }

  int bufferSize = strlen((const char *)prefix) + strlen((const char *)localName) + 1 + 1; 
  char qualifiedNameBuffer[bufferSize];

  strlcpy(qualifiedNameBuffer, (const char *)prefix, sizeof(qualifiedNameBuffer));
  const char *colon = ":";
  strlcat(qualifiedNameBuffer, colon, sizeof(qualifiedNameBuffer));

  strlcat(qualifiedNameBuffer, (const char*)localName, sizeof(qualifiedNameBuffer));
  return [[NSString alloc] initWithUTF8String:qualifiedNameBuffer];
}

static void 
startDocumentSAX (void * ctx)
{
}

static void 
endDocumentSAX (void * ctx)
{
}

static id
nustring(NSString *string) {
  return _nustring([string cStringUsingEncoding: NSUTF8StringEncoding]);
}

static void
startElementSAX(void *ctx,
                const xmlChar *localname,
                const xmlChar *prefix,
                const xmlChar *URI,
                int nb_namespaces,
                const xmlChar **namespaces,
                int nb_attributes,
                int nb_defaulted,
                const xmlChar **attributes)
{
  NSString *qualifiedName = [[NSString alloc] initWithUTF8String:(const char *)localname];
  if (prefix) {
    qualifiedName = getQualifiedName(prefix, localname);
  }
  NuSAX *currentReader = (NuSAX *)ctx;
  
  id element = nustring(qualifiedName);
  [currentReader.processed addObject: element];
  [currentReader.processed addObject: _nunull()];
  
  
  NSUInteger attributeCounter, maxAttributes = nb_attributes * 5;
  for (attributeCounter = 0; attributeCounter < maxAttributes; attributeCounter++) {
      NSString *localNameString = nil;
      NSString *prefixString = nil;
      NSString *URIString = nil;
      NSString *valueString = nil;
      
      BOOL releaseLocalNameString = NO;
      
      const xmlChar *localName = attributes[attributeCounter];

      attributeCounter++;
      const xmlChar *attributePrefix = attributes[attributeCounter];
      
      attributeCounter++;
      const char *URI = (const char *)attributes[attributeCounter];
      if (URI) {
          URIString = [[NSString alloc] initWithUTF8String:URI];
      }
      
      attributeCounter++;
      
      const char *valueBegin = (const char *)attributes[attributeCounter];
      const char *valueEnd = (const char *)attributes[attributeCounter + 1];
    
      if (valueBegin && valueEnd) {
          valueString = [[NSString alloc] initWithBytes:attributes[attributeCounter] length:(strlen(valueBegin) - strlen(valueEnd)) encoding:NSUTF8StringEncoding];
      }
      
      attributeCounter++;
      
      if (attributePrefix) {
          localNameString = getQualifiedName(attributePrefix, localName);
          releaseLocalNameString = YES;
      } else {
          localNameString = [[NSString alloc] initWithUTF8String:(const char *)localName];
      }
      
      if (valueString) {
        id last = [currentReader.processed lastObject];
        [currentReader.processed removeLastObject];
        
        last = _nucell(_nucell(nustring(localNameString), _nucell(nustring(valueString), _nunull())), last);
        [currentReader.processed addObject: last]; 
      }
      
      if (releaseLocalNameString) {
          [localNameString release];
      }
      
      if (valueString) {
          [valueString release];
      }
  }
  
  if (qualifiedName) {
    [qualifiedName release];
  }
}

static id 
cellList(NSMutableArray *array, NSString *target, id cell) {
  id lastCell = [array lastObject];
  [array removeLastObject];
  if ([target isEqualToString: [lastCell stringValue]]) {
    return _nucell(lastCell, cell);
  } else {
    return cellList(array, target, _nucell(lastCell, cell));
  }
}

static void	
endElementSAX (void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI) {
  NuSAX *currentReader = (NuSAX *) ctx;

  NSString *qualifiedElementName = [[NSString alloc] initWithUTF8String:(const char *)localname];
  if (prefix) {
    qualifiedElementName = getQualifiedName(prefix, localname);
  }

  id lastCell = [currentReader.processed lastObject];
  [currentReader.processed removeLastObject];
  id x = cellList(currentReader.processed, qualifiedElementName, _nucell(lastCell, _nunull()));
  [currentReader.processed addObject: x];
    
  if (qualifiedElementName) {
    [qualifiedElementName release];
  }
}

static void	
charactersFoundSAX	(void * ctx, const xmlChar * ch, int len) {
  NuSAX *currentReader = (NuSAX *)ctx;
  
  CFStringRef str = CFStringCreateWithBytes(kCFAllocatorSystemDefault, ch, len, kCFStringEncodingUTF8, false);
  NSMutableString *string = [[NSMutableString alloc] initWithCapacity: 0];
  [string appendString:(NSString *)str];
  string = [string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if ([[string stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]] length] > 0) {
    [currentReader.processed addObject: nustring(string)];
  }
}

static void 
errorEncounteredSAX (void * ctx, const char * msg, ...) {
  NSLog(@"error: %s", msg);
}

static void 
fatalErrorEncounteredSAX (void * ctx, const char * msg, ...) {
  NSLog(@"fatal error: %s", msg);
}

@end
