
# General

This is a simple ECS system.
Still a WIP

# General Idea

In a traditional ECS System, the components are lined up in an array for high performance processing within the same System.
I am not interested in that part for ECS.
Instead I am interested in the following.

1. Having generic Entity data object instead of using inheritance for various entities in the game.
2. Moving all logics from entity into systems.
3. Messaging as a mechanism for propagating changes and informing system.

One big difference is that ECS usually comes with a RenderSystem.
Try to shape heaps into ECS with a RenderSystem added a lot of weird complexity.
Because of this, in this ECS we will attempt to not use a RenderSystem.
Instead, have each entity extends from h2d.Layers.

Inheriting from h2d.Layers also means that positionComponent is useless as well, since they already have a x/y for drawing.

We will do 3D in a different package later.

There will still need for a render system. However the implementation of the render system will be slightly different.
For the render system, we will set up the camera + foreground, background, world.
All entities will be added to the "world".
Foregrounds are for menus and HUD, and background are for background, duh..
Camera will only be applied on world.
