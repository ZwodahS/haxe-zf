# Ren

The goal of ren (Roguelike ENgine) is to provide a abstraction layer to make traditional roguelike easier to make for me.

It will provide systems for commonly used features in roguelike.
These features can be opt in by adding them into the World.
Some systems depends on others, but most of them are only loosely coupled by events.

Previously ren is in a separate repo and that makes maintaining it hard.
After launching 2 games, zf has changed a lot and ren no longer works.
The way that things are done previously is also outdated and many new tools are added to zf.

Since I plan to make a few roguelike, it is time to modernise ren and move it into zf.
By putting in zf, it will be easier to maintain it.

# Dependencies
To use ren, there are some libraries that are required in additional to heaps

- astar for pathfinding

# Core
The core part of ren

These classes are required and is always there.

# Ext
Individual systems that can be added if necessary.
They can be extended or use as is.
