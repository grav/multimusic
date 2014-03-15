Mumu
==========

Mumu (or Multi Music) is an audio player that is able to playback audio from various sources. This way, you only need one player, no matter where your music comes from.

Currently, the only source supported is the mumu server, but Spotify and Soundcloud support is in the pipeline.

Components
----------

Mumu consists of the following components:

- iOS mobile app that supports the various audio sources
- mumu server, a simple python scripts that reads metadata from all media files in a directory and exposes the metadata and the media files via HTTP

Roadmap
-------

Mumu will eventually support more sources throught various APIs. Spotify and Soundcloud support is planned.

The mumu server will eventually support periodic reload of library data, and authentication over HTTP.





