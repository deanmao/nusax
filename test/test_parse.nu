(load "NuSAX")

(class TestParse is NuTestCase
     (- testParseXML is
        (set parser ((NuSAX alloc) init))
        (set output (parser parseXML:"<fruits><apple  version=\"3.0\" language=\"english\">blah</apple><orange>foo</orange></fruits>" 
                            parseError:nil))
        (assert_equal ('(fruits () (apple ((language english) (version "3.0")) blah) (orange () foo)) stringValue) 
                      (output stringValue)))
                      
    (- testFromXml is
       (assert_equal ('(test ()) stringValue) 
                     (("<test></test>" fromXml) stringValue)))
                              
    (- testFromXmlToXml is
       (set blah "<test><blah>123</blah></test>")
       (assert_equal blah 
                     ((blah fromXml) toXml)))
  
    (- testXmlString is
       (set output ('(test ()) toXml))
       (assert_equal "<test></test>" output))

   (- testXmlString2 is
      (set output ('(fruits () (apple ((version "3.0") (language english)) blah) (orange () foo)) toXml))
      (assert_equal "<fruits><apple version=\"3.0\" language=\"english\">blah</apple><orange>foo</orange></fruits>" output))

    (- testXmlString3 is
       (set output ('(test () (blah () blah)) toXml))
       (assert_equal "<test><blah>blah</blah></test>" output)))