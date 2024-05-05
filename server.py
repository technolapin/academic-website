import http.server
import socketserver
import os

# Set the port you want to use. By default, HTTP servers use port 8000.
PORT = 9000

#ROOT_PAGE = "/build/index.html"
ROOT_PAGE = "/build/20240505014503-about_me.html"
print(ROOT_PAGE)

# Create a handler to serve the files from the specified directory.
class CustomHandler(http.server.SimpleHTTPRequestHandler):
    # Override the method to handle root URL redirection
    def do_GET(self):
        print("path", self.path)
        if self.path == "/":
            self.path = ROOT_PAGE
        if self.path.count("/") == 1:
            self.path = "/build/" + self.path
        return http.server.SimpleHTTPRequestHandler.do_GET(self)

# Set up the server.
with socketserver.TCPServer(("", PORT), CustomHandler) as httpd:
    print("Serving at port", PORT)
    # Serve indefinitely until interrupted.
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.")
