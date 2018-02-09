import SimpleHTTPServer
import SocketServer
from parseurl import parseurl, parse_qs

PORT = 8000

class fireHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        query = parse_qs(urlparse(self.path).query)
        _cb   = query['cb'][0]
        _zip  = query['zip'][0]
