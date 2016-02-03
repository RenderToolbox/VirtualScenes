# VirtualScenes
With RenderToolbox3, render scenes with random objects, materials, and lights.

# Installing

### RenderToolbox3
VirtualScenes is an extension to RenderToolbox3.  So first you must try  [Installing-RenderToolbox3](https://github.com/RenderToolbox3/RenderToolbox3/wiki/Installing-RenderToolbox3).

To verify your installation, run `RenderToolbox3InstallationTest()`.

### RGB version of Mitsuba
VirtualScenes uses a feature of the Mitsuba renderer to extract ground truth data from a scene.  Some of the ground truth "factoids" only work when Mitsuba is compiled in RGB mode.  So you'll need two builds of Mitsuba: one for spectral rendering and one for RGB factoids.

Building the RGB version should go just like the [spectral build](https://github.com/RenderToolbox3/RenderToolbox3/wiki/Building-Renderers#mitsuba).  You just have to edit your `config.py` with  `-DSPECTRUM_SAMPLES=3`, and then run `scons`.

You will now have two flavors of Mitsuba to manage.

On OS X, you'll have two flavors of `Mitsuba.app`.  Rename the RGB version to `Mitsuba-RGB.app` and put both of them somewhere you can remember, perhaps your `/Applications` folder.

On Linux, you'll have two flavors of the `dist` folder which is produced by the build.  Copy the spectral version to a folder named `mitsuba`, copy the RGB version to a folder named `mitsuba-rgb`, and put them both somewhere you can remember, perhaps `/usr/local/` or your home folder.

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

# Using

### Generate a Boat Load of Virtual Scenes
VirtualScenes can generate random scenes by insterting random objects at random positions into existing "base scenes".

Try running `MakeManyWardlandRecipes.m` to generate 24 of these scenes.  This should not take too long because we're just generating rendering recipes.  We're not rendering yet.

### Render a Boat Load of Virtual Scenes
Now you have 24 recipes ready for rendering.

Try running `ExecuteManyWardLandRecipes.m` to start some renderings.  By default, this will render all 24 scenes, which may take a while.  For a quicker preview, edit line.  Change the value of `nScenes` to some smaller number, like 1:
```
%nScenes = numel(archiveFiles);
nScenes = 1;
```

### Analyze a Boat Load of Renderings
Now you have up to 24 renderings.  What do they look like?  What are some statistics about them.

Try running `AnalyzeManyWardLandRecipes.m` to analyze the renderings you just executed.  By default, this will analyze the same number of renderings executed in the previous step.

`AnalyzeManyWardLandRecipes.m` is one example how to locate VirtualScenes data and do some analysis on it.  You could copy this script and modify it for other analyses.
