
# Ideas
In a traditional ECS System, the components are lined up in an array for high performance processing within the same System.
I am not interested in the optimisation since most of the games I made aren't performance heavy.
If I need performance, I will just go lower.

Instead I am interested in the following.

1. Having generic Entity data object instead of using inheritance for various entities in the game.
2. Having Systems hold all the game logic, and having the entity just hold the data and their invariant.
3. Using messaging as a mechanism for propagating changes and informing system.

In the previous implementation, I had made a generic Entity, which is composed using Component.
However it makes it extremely verbose, and had to do alot of type casting and stuffs, making the code hard to read.

This iteration is allows for a more specialised Entity Object, rather than using a generic Entity object.
The solution is to have each games that uses this ECS extends from the Entity object.

The World and System object is also implemented with generic.
The world object of each new games should ideally implement their own World and System objects.

Wed Nov 11 23:19:53 2020
This is deprecated, but kept here for older project.
I need to move away from generic, since it complicated things.
