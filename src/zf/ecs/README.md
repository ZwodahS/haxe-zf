# Ideas
In a traditional ECS System, the components are lined up in an array for high performance processing within the same System.
I am not interested in the optimisation since most of the games I made aren't performance heavy.

Instead I am interested in the following.

1. Having generic Entity data object instead of using inheritance for various entities in the game.
2. Having Systems hold all the game logic, and having the entity just hold the data.
3. Using messaging as a mechanism for propagating changes and informing system.

In short, the ECS here is not for performance but for easy management of logic and code. This might change in the future when I need to handle more real time games.
