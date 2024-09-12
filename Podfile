use_frameworks!

platform :ios, '15.0'

target 'POC Tangem Solana' do
  pod 'TangemSdk', :git => 'https://github.com/Tangem/tangem-sdk-ios.git', :tag => 'develop-302'
  pod 'Solana.Swift', :git => 'https://github.com/tangem/Solana.Swift', :tag => '1.2.0-tangem10'
end

pre_install do |installer|
  # workaround for https://github.com/CocoaPods/CocoaPods/issues/3289
  Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    if config.name.downcase.include?("debug")
      config.build_settings['GCC_OPTIMIZATION_LEVEL'] = '0'
      config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      config.build_settings['ENABLE_TESTABILITY'] = 'YES'
      config.build_settings['SWIFT_COMPILATION_MODE'] = 'Incremental'
    end
    
    # Fix warnings on Xcode 15 https://indiestack.com/2023/10/xcode-15-duplicate-library-linker-warnings/
    config.build_settings['OTHER_LDFLAGS'] ||= ['$(inherited)']
    config.build_settings['OTHER_LDFLAGS'] << '-Wl,-no_warn_duplicate_libraries'
    config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
  end
  
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
      
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.5'
    end
  end
  
  # `secp256k1.swift` SPM package for `Solana.Swift` pod
  add_spm_package_to_target(
    installer.pods_project,
    "Solana.Swift",
    "https://github.com/GigaBitcoin/secp256k1.swift.git",
    "secp256k1",
    { :kind => "upToNextMinorVersion", :minimumVersion => "0.12.0" }
  )
                            
  # `TweetNacl` SPM package for `Solana.Swift` pod
  add_spm_package_to_target(
    installer.pods_project,
    "Solana.Swift",
    "https://github.com/bitmark-inc/tweetnacl-swiftwrap.git",
    "TweetNacl",
    { :kind => "exactVersion", :version => "1.1.0" }
  )
                                                      
end

# Adds given SPM package as a dependency to a specific target in the `Pods` project.
# TODO: Extract this logic to a dedicated CocoaPods plugin (IOS-5855)
#
# Valid values for the `requirement` parameter are:
# - `{ :kind => "upToNextMajorVersion", :minimumVersion => "1.0.0" }`
# - `{ :kind => "upToNextMinorVersion", :minimumVersion => "1.0.0" }`
# - `{ :kind => "exactVersion", :version => "1.0.0" }`
# - `{ :kind => "versionRange", :minimumVersion => "1.0.0", :maximumVersion => "2.0.0" }`
# - `{ :kind => "branch", :branch => "some-feature-branch" }`
# - `{ :kind => "revision", :revision => "4a9b230f2b18e1798abbba2488293844bf62b33f" }`
def add_spm_package_to_target(project, target_name, url, product_name, requirement)
  project.targets.each do |target|
    if target.name == target_name
      pkg = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
      pkg.repositoryURL = url
      pkg.requirement = requirement
      ref = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
      ref.package = pkg
      ref.product_name = product_name
      target.package_product_dependencies << ref

      project_already_has_this_pkg = false

      project.root_object.package_references.each do |existing_ref|
        if existing_ref.display_name.downcase.eql?(url.downcase)
          project_already_has_this_pkg = true
          break
        end
      end

      unless project_already_has_this_pkg
        project.root_object.package_references << pkg
      end

      target.build_configurations.each do |config|
        config.build_settings['SWIFT_INCLUDE_PATHS'] = '$(inherited) ${PODS_BUILD_DIR}/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)'
      end
    end
  end

  project.save
end
