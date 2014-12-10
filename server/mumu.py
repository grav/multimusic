#!/usr/bin/env python

from twisted.web import server, resource, static
from twisted.internet import reactor
import mutagen
import json
import os
import sys

# default folder for media files
MEDIA = 'media'

LIBRARY = 'library.json'

# default server port
PORT = 8000

def serve(media,port):
    root = static.File(media)
    reactor.listenTCP(port, server.Site(root))
    print "serving at port", port
    reactor.run()

def metadata(path):
    filenames = [path+'/'+filename for filename in os.listdir(path)]
    filenames = filter(lambda x: x.endswith('mp3'),filenames)
    metas = [mutagen.File(filename,easy=True) for filename in filenames]
    metas_filtered = [{k : meta[k][0] for k in ['artist', 'title','album'] if meta[k]} for meta in metas]
    filenames_dict = [{"filename" : filename} for filename in filenames]
    return [dict(a.items()+b.items()) for a,b in zip(filenames_dict,metas_filtered)]
        
media = sys.argv[1] if len(sys.argv) >= 2 else MEDIA
port = int(sys.argv[2]) if len(sys.argv) >= 3 else PORT

d = {"tracks":metadata(media)}

jsn = json.dumps(d)

with open(media+"/"+LIBRARY, "w") as f:
    f.write(jsn)

print "Loaded %d files into library." % len(d["tracks"])

serve(media,port)
