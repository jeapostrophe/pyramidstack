#lang scribble/manual
@(require (for-label (except-in scheme/base path?)
                     scheme/contract))

@title{Pyramid Stack}
@author{@(author+email "Jay McCarthy" "jay@plt-scheme.org")}

This package contains two demos that show off the Chipmunk and GL APIs. These are not intended to be required as libraries, but rather run to show off PLT Scheme or studied to build your own simulation.

@section{Chipmunk and Universe}

@defmodule[(planet jaymccarthy/pyramidstack/pyramidstack)]

This module use the Chipmunk API to simulate a pyramid of circles where the top circle has more mass and can be controlled by the user with the arrow keys. It uses the Universe interface to render the scene and allow the user to influence the simulation. Chipmunk does not know anything about the display, but in this demo the display closely corresponds to what is in the simulation.

Even though this uses the functional Universe interface, it is not a functional program because the Chipmunk physics engine cannot be interacted with functionally. As you will see, the World object is simply a count of the number of steps the simulation has taken.

(NB: This seems to cause an intermittent bug in the early August SVN version of the Universe library; if you get it, try to re-run.)

@section{Chipmunk and OpenGL}

@defmodule[(planet jaymccarthy/pyramidstack/gl-pyramidstack)]

This module is roughly the same as the other except that it uses the OpenGL World interface and the 2D OpenGL interface for its display. Since OpenGL supports rotation, but the @schememodname[htdp/image] library does not, it has a pyramid of blocks that are textured as the DrScheme @onscreen{Stop} icon to show that as they fall and are pushed around they rotate. This demo also shows off the 2D OpenGL interface's support for viewports: the viewport is half the size of entire world and is centered around the black ball. In a platform video game, this would be used to center the interface around the player, while simulating a larger space.