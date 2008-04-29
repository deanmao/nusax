(set platform "native")

(case platform
      ("iPhone"
               (set PLATFORM "-isysroot /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS2.0.sdk")
               (set @arch '("armv6"))
               (set @cc "/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/gcc-4.0"))
      ("simulator"
                  (set PLATFORM "-isysroot /Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator2.0.sdk")
                  (set @arch '("i386")))
      ("native"
                  (set @cc "/Developer/usr/bin/gcc-4.2")
                  (set PLATFORM "")
                  (set @arch '("i386")))
      (else nil))

(set @cflags "-I /usr/include/libxml2 -g -ObjC -Iinclude -std=gnu99 #{PLATFORM} -mmacosx-version-min=10.5")

(set @h_files	  (filelist "^objc/.*.h$"))
(set @m_files     (filelist "^objc/.*.m$"))
(set @nu_files 	  (filelist "^nu/.*nu$"))
(set @frameworks  '("Cocoa" "Nu"))
(set @libs '("xml2"))

(set @ldflags
     ((list
           ((@frameworks map: (do (framework) " -framework #{framework}")) join)
           ((@libs map: (do (lib) " -l#{lib}")) join)
           ((@lib_dirs map: (do (libdir) " -L#{libdir}")) join))
      join))

(set @framework "NuSAX")
(set @framework_identifier "nu.programming.nusax")
(set @framework_creator_code "????")

(compilation-tasks)
(framework-tasks)

(task "framework" => "#{@framework_headers_dir}/NuSAX.h")

(ifDarwin
         (file "#{@framework_headers_dir}/NuSAX.h" => "objc/NuSAX.h" @framework_headers_dir is
               (SH "cp objc/NuSAX.h #{@framework_headers_dir}")))

(task "test" => "framework" is
     (SH "nutest test/test_*.nu"))
                     
(task "default" => "framework")

(task "clobber" => "clean" is
      (SH "rm -f example1"))

(task "install" => "framework" is
      (SH "ditto #{@framework_dir} /Library/Frameworks/#{@framework_dir}"))

(task "example" is
      (SH "#{@cc} examples/example1.m -o example1 -lxml2 -I/usr/include/libxml2 -framework Cocoa -framework NuSAX"))
