# Changes from the original ren

## Path changes
Previously all module in zf.ren.ext is structed as zf.ren.ext.(systems/message/components).
I don't like this approach for ext since I can't just import the whole module

Instead, for ext specifically, we will move to zf.ren.ext.(module) and put all the related objects in the module instead.

zf.ren.ext.(messages/components) still exists for common stuffs.

## Mark for destroy
Previously there was a message to mark entity to be destroyed.
I don't like the current implementation so I will need to rethink it first before putting it in ren.

## Location Component
LocationComponent.tile is now a getter rather than a field.
I can't remember why it needs to be a field since we can use level.getTile to get it.

## Visibility & Fog
Mon 16:58:29 18 Nov 2024
Visibility and fog is not implemented yet.
Will have to do it later.
Ideally we should not put it in zf.ren.ext.tbr
It should probably be its own module
