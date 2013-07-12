#Anchovy

Set of multimedia libraries for games and gui applications.
Currently in active development, so usage in big projects is not recomended.
API can change with every version.

#Structure:
* anchovy.core - basic interfaces.
* anchovy.utils - additional helpers.
* anchovy.graphics - windowing and rendering. 
* anchovy.gui - skinnable graphical interface. The only usable package right now.
planned packages:
* anchovy.audio - OpenAL sound manager.
* anchovy.network - client-server framework.
* anchovy.locale - translation management.

#Dependencies:
* dlib
* Derelict:
* |-util
* |-opengl3
* |-glfw3
* |-sdl2 // currenntly optional.
* |-freeimage
* |-freetype

#Contributing:
Any improvements, bug reports, feature-requests are appreciated.

#TODO
todo list is located at trello [trello](https://trello.com/board/anchovy/51c5d5e99f73cd373e00105a)