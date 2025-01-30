# bondgrid

<h1> Setup Guide</h1>
<p>1. Download the following installation bundle to get the latest stable release of the Flutter SDK:</p>
<p> https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.3.9-stable.tar.xz</p>
<p>2. Extract the file in the desired location,</p>
<p>3. Add the flutter tool to your path:</p>
<p>export PATH="$PATH:`pwd`/flutter/bin"</p>

<h2>Run flutter doctor</h2>
<p>Run the following command to see if there are any dependencies you need to install to complete the setup (for verbose output, add the -v flag):</p>
<p>flutter doctor</p>

<h2>Other Requirements</h2>
<p>Install Android Studio</p>
<p>Accept licences using command: flutter doctor --android-licenses</p>
<p>Install Android SDK command line tools</p>
<ol>
    <li>Go to SDK Manager in Android Studio.</li>
    <li>In the SDK Platforms tab, select API 32.</li>
    <li>In the SDK Tools tab, select Android SDK Command-line Tools(latest).</li>
    <li>Click Apply and then OK to install the SDK.</li>
</ol>

<h1>Command to run App</h1>
  <p>Navigate to bondgrid folder</p>
  <p>Run command: flutter run -d chrome --web-renderer html</p>
  <p>Run on Android Studio Simulator: flutter run</p>
# finvest
