#!/usr/bin/env python3
"""
Простой HTTP сервер для выполнения shell команд в UI тестах.
Позволяет удалённо управлять симуляторами при параллельном запуске тестов.

Usage:
    ./AutotestsLocalWebServer.py [<port>]
    По умолчанию используется порт 63281
"""
import os
from http.server import BaseHTTPRequestHandler, HTTPServer
import logging


class AutotestsLocalWebServer(BaseHTTPRequestHandler):

    def _set_response(self):
        self.send_header('Content-type', 'text/plain')
        self.end_headers()

    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        logging.info("POST request,\nPath: %s\nHeaders:\n%s\n\nBody:\n%s\n",
                     str(self.path), str(self.headers), post_data.decode('utf-8'))

        exit_code = os.system(post_data.decode('utf-8'))
        if exit_code == 0:
            self.send_response(200)
        else:
            self.send_response(500)
        self._set_response()
        self.wfile.write("Exit code: {}".format(exit_code).encode('utf-8'))

    def do_GET(self):
        self.send_response(200)
        self._set_response()
        self.wfile.write(b"AutotestsLocalWebServer is running")


def run(server_class=HTTPServer, handler_class=AutotestsLocalWebServer, port=63281):
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    logging.info('Starting AutotestsLocalWebServer on port %d...', port)
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    logging.info('Stopping AutotestsLocalWebServer...\n')


if __name__ == '__main__':
    from sys import argv

    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()
