import SimpleHTTPServer
import SocketServer
import kaa.metadata
import json
import os

# folder for media files
MEDIA = 'media'
LIBRARY = 'library.json'

# server port
PORT = 8000

def serve():
    Handler = SimpleHTTPServer.SimpleHTTPRequestHandler
    httpd = SocketServer.TCPServer(("", PORT), Handler)
    print "serving at port", PORT
    httpd.serve_forever()

def metadata(path):
    filenames = [path+'/'+filename for filename in os.listdir(path)]
    metas = [kaa.metadata.parse(filename) for filename in filenames]
    metas_filtered = [{k : meta[k] for k in ['artist', 'title','album']} for meta in metas]
    filenames_dict = [{"filename" : filename} for filename in filenames]
    return [dict(a.items()+b.items()) for a,b in zip(filenames_dict,metas_filtered)]
        
d = {"tracks":metadata(MEDIA)}

jsn = json.dumps(d)

with open(LIBRARY, "w") as f:
    f.write(jsn)

print "Loaded %d files into library." % len(d)

serve()




