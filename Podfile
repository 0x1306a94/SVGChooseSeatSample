# Uncomment the next line to define a global platform for your project
platform :ios, "14.0"

inhibit_all_warnings!
install! "cocoapods",
  #  :disable_input_output_paths => true,
  generate_multiple_pod_projects: true,
  warn_for_unused_master_specs_repo: false

target "SVGChooseSeatSample" do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod "YYModel"
  # Pods for SVGChooseSeatSample

  target "SVGChooseSeatSampleTests" do
    inherit! :search_paths
    # Pods for testing
  end

  target "SVGChooseSeatSampleUITests" do
    # Pods for testing
  end
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "13.0"
      end
    end
  end
end
