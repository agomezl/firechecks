from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import SocketServer
from urlparse import urlparse, parse_qs

PORT = 8082
ENPOINT = ['/lab92']

class fireHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        request = urlparse(self.path)
        query   = parse_qs(request.query)
        path    = request.path
        _cb     = query['cb'][0]
        _zip    = query['zip'][0]

        if path in ENPOINT:
            self.send_response(200, 'Ok')
        else:
            self.send_error(404, 'Path is not defined')
        self.end_headers()
        return

def run():
  print('http server is starting...')

  #ip and port of server
  #by default http server port is 80
  server_address = ('localhost', PORT)
  httpd = HTTPServer(server_address, fireHandler)
  print('http server is running on port %s...' % PORT)
  httpd.serve_forever()

if __name__ == '__main__':
  run()
