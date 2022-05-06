# Overview
The `ui.builder` module allows for creation of ui from configuration.
Currently there are 2 mode that are supported; json and xml.
Unlike `zf.tui` the struct used in `ui.builder` will use mostly primitive types (i.e. String, Int).
For some specific cases, non-primitive type can be used but those will not be available when loading from file.
Therefore, this will not be a drop in replacement for `zf.tui`
Eventually zf.tui will be deprecated in favor of `ui.builder`

# Motivation
There are times where we need to create static object.

The first method is to place the object manually.
Many of the methods in `zf.h2d.ObjectExtensions`, together with `h2d.Flow` helps with this.
However this turns out to be extremely tedious.

The next logic step is create a way to specify a anon struct and a factory will create the object.
This was previously created as `zf.tui` module.

Due to the implementation of zf.tui using many of the native object and are non-text, we couldn't load it from file.
Instead, we will need to define a format to load it from file, this is similar to `domkit`
Unlike domkit, there is no intention to deal with CSS.
Instead, most of the property of the object will be exposed as attributes in the struct/xml instead.

# Usage
See `ui.builder.Builder`
