#Anchovy

Set of multimedia libraries for games and gui applications.
Currently in active development, so usage in big projects is not recomended.
API can change with every version.

![v0 6 0](https://cloud.githubusercontent.com/assets/1129910/3053639/9b3fac46-e1ac-11e3-8ba7-4ae4a67788d4.png)

##Structure:
* anchovy.core - basic interfaces.
* anchovy.utils - additional helpers.
* anchovy.graphics - windows and rendering.
* anchovy.gui - skinnable graphical interface. The only usable package right now.

##Dependencies:
* dlib - vectors and matrixes
* sdlang-d - gui markup files are stored in .sdl files
* derelict-fi - for image loading (may be replaced by dlib image loader in the future).
* derelict-ft - font rendering
* derelict-gl3 - OpenGL renderer
* derelict-glfw3 - window creation, input handling
* derelict-sdl2 - window creation, input handling (abandoned)
* derelict-util - used by other derelict packages

##Contributing:
Any improvements, bug reports, feature-requests are highly appreciated.

##Building
###Windows and linux

Now the library can be built with dub.

To use in your project put a dependency like:
```
"dependencies": {
	"anchovy": ">=0.6.1"
}
```

To build example application execute in root folder:
```
dub build anchovy:example01 --build=debug --nodeps
```

In order to run compiled example you will need to download resourses from [latest release](https://github.com/MrSmith33/anchovy/releases) and install libraries if you are on linux. (glfw3, freetype, freeimage)
