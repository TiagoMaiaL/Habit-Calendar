# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

def shared_pods
    pod 'JTAppleCalendar', '~> 7.1.6'
    pod 'SwiftLint'
    pod 'UIColor_Hex_Swift', '~> 4.0.2'
end

target 'Habit-Calendar' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Active
  shared_pods

  target 'Habit-Calendar-Dev' do
    shared_pods
  end

  target 'Habit-Calendar-Stg' do
    shared_pods
  end

  target 'Habit-CalendarTests' do
    inherit! :search_paths
    # Pods for testing
  end

end
