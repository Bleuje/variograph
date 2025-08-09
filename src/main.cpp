#include "ofMain.h"
#include "ofApp.h"

//========================================================================
int main( ){
    // openGL 4.3
    ofGLWindowSettings settings;
    settings.setGLVersion(4,3);
    settings.setSize(1600,900);
    //settings.windowMode = OF_FULLSCREEN;
    ofCreateWindow(settings);
    ofRunApp(new ofApp());

}
