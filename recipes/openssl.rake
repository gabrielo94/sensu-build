Bunchr::Software.new do |t|
  t.name = 'openssl'
  t.version = '1.0.1t'

  assets_dir = "#{Dir.pwd}/assets"

  install_prefix = "#{Bunchr.install_dir}/embedded"

  ## download_commands are executed in the +download_dir+ directory.
  github_version = t.version.gsub(".", "_")
  t.download_commands << "mkdir openssl-#{t.version}"
  t.download_commands << "curl -L https://github.com/openssl/openssl/archive/OpenSSL_#{github_version}.tar.gz | tar -xzC openssl-#{t.version} --strip-components=1"

  ## build_commands are executed in the +work_dir+ directory.
  ## If work_dir is not specified, it is assumed to be "name-version" or "name"
  ## which is typically the case for tarballs.  Can be overriden here, eg:
  ##  t.work_dir = "openssl"

  os   = t.ohai['os']
  arch = t.ohai['kernel']['machine']

  if os == 'darwin' && arch == 'x86_64'
    # mac 64bit specifics
    t.build_commands << "./Configure darwin64-x86_64-cc  \
                        --prefix=#{install_prefix} \
                        --with-zlib-lib=#{install_prefix}/lib \
                        --with-zlib-include=#{install_prefix}/include \
                        zlib shared"
  elsif os == 'solaris2'
    # solaris2 specifics
    t.build_commands << "./Configure solaris-x86-gcc \
                        --prefix=#{install_prefix} \
                        --with-zlib-lib=#{install_prefix}/lib \
                        --with-zlib-include=#{install_prefix}/include \
                        zlib shared \
                        -L#{install_prefix}/lib \
                        -I#{install_prefix}/include \
                        -R#{install_prefix}/lib"
  else
    # all other platforms
    t.build_commands << "./config \
                        --prefix=#{install_prefix} \
                        --with-zlib-lib=#{install_prefix}/lib \
                        --with-zlib-include=#{install_prefix}/include \
                        zlib shared \
                        -L#{install_prefix}/lib \
                        -I#{install_prefix}/include"
  end
  t.build_environment['LD_RUN_PATH'] = "#{install_prefix}/lib"

  if arch == "armv6l" || arch == "armv7l"
    t.build_commands << "sed -i -e 's/armv7-a/armv6/g' Makefile"
  end

  t.build_commands << "make"

  ## install_commands are executed in the +work_dir+ directory.
  t.install_commands << "make install"
  t.install_commands << "rm -rf #{install_prefix}/ssl/man"

  t.install_commands << "cp -f #{assets_dir}/cacert.pem #{install_prefix}/ssl/cert.pem"

  CLEAN << install_prefix
end
