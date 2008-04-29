#!/usr/bin/env nush

(load "NuSAX")
(load "Cocoa")

(set parser ((NuSAX alloc) init))
(set x (parser parseXML:"<fruits><apple  version=\"3.0\" language=\"english\">blah</apple><orange>foo</orange></fruits>" 
               parseError:nil))

(puts "list form:")               
(puts x)

(puts "xml form:")
(puts (x toXml))