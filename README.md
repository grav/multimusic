Mumu
==========

Mumu (or Multi Music) is an audio player that is able to play back audio from various sources. This way, you only need one player, no matter where your music comes from.

Components
----------

Mumu consists of the following components:

- iOS mobile app that supports the various audio sources (currently Spotify, Soundcloud and files hosted via the mumu server) 
- mumu server, a simple python script that reads metadata from all media files in a directory and exposes the metadata and the media files via HTTP. 

Roadmap
-------

Mumu will eventually support more sources through various APIs, such as Deezer, Wimp, iTunes library ...

Also, search across the different channels is in implementation progress.

The mumu server will eventually support periodic reload of library data, transcoding of media files, and authentication over HTTP.





