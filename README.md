# VirtualScenes
With RenderToolbox3, render scenes with random objects, materials, and lights.

# Gettint Started

### RenderToolbox3
VirtualScenes is an extension to RenderToolbox3.  So first you must try  [Installing-RenderToolbox3](https://github.com/RenderToolbox3/RenderToolbox3/wiki/Installing-RenderToolbox3).

To verify your installation, run `RenderToolbox3InstallationTest()`.

### RGB version of Mitsuba
VirtualScenes uses a feature of the Mitsuba renderer to extract ground truth data from a scene.  Some of the ground truth "factoids" only work when Mitsuba is compiled in RGB mode.  So you'll need two builds of Mitsuba: one for spectral rendering and one for RGB rendering.

Building the RGB version should go just like the spectral build.  You just have to edit your `config.py` with  `-DSPECTRUM_SAMPLES=3`, and then run `scons`.

You will now have two flavors of Mitsuba to manage.

On OS X, you'll have two versions of `Mitsuba.app`.  Rename the RGB version to `Mitsuba-RGB.app` and put both of them somewhere you can remember, perhaps your `/Applications` folder.

On Linux, you'll have two versions of the `dist` folder which is produced by the build.  Copy the spectral version to a folder named `mitsuba`, copy the RGB version to a folder named `mitsuba-rgb`, and put them both somewhere you can remember, perhaps `/usr/local/` or your home folder.

### VirtualScenes Configuration
Git clone this repository and add to your Matlab path.
```
git clone https://github.com/RenderToolbox3/VirtualScenes.git
# add VirtualScenes to Matlab path, with subfolders
```

Make a copy of `VirtualScenesConfigurationTemplate.m` and edit it.

On OS X, make sure `setpref('MitsubaRGB', 'app', ...);` points to your own `Mitsuba-RGB.app`.

On Linux, make sure `setpref('MitsubaRGB', 'executable', ...);` and `setpref('MitsubaRGB', 'importer', ...);` point into to your own `mitsuba` and `mitsuba-rgb` folders.

Now execute your copy of `VirtualScenesConfigurationTemplate.m`.

*Don't for get to execute it!*
