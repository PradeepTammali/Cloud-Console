from werkzeug import serving
from flask_sockets import Sockets
from flask import Flask, render_template
from utility.log import log
from utility.k8s import K8SClient, K8SStreamThread
import os

app = Flask(__name__, static_folder='static',
            static_url_path='/terminal/static')
sockets = Sockets(app)


@app.route('/', methods=['GET'])
def index():
    return render_template('index.html')


@app.route('/terminal/window', methods=['GET'])
def terminal():
    return render_template('terminal.html')


@sockets.route('/terminal/<namespace>/<pod>/<container>/<token>')
def terminal_socket(ws, namespace, pod, container, token):
    log.info('Try create socket connection')
    kub = K8SClient(
        api_server=os.environ["API_SERVER"].rstrip("/"), id_token=token)
    try:
        container_stream = kub.terminal_start(namespace, pod, container)
    except Exception as err:
        log.error('Connect container error: {}'.format(err))
        ws.close()
        return

    kub_stream = K8SStreamThread(ws, container_stream)
    kub_stream.start()

    log.info('Start terminal')
    try:
        while not ws.closed:
            message = ws.receive()
            if message is not None:
                if message != '__ping__':
                    container_stream.write_stdin(message)
        container_stream.write_stdin('exit\r')
    except Exception as err:
        log.error('Connect container error: {}'.format(err))
    finally:
        container_stream.close()
        ws.close()


@serving.run_with_reloader
def run_server():
    app.debug = True
    from gevent import pywsgi
    from geventwebsocket.handler import WebSocketHandler
    server = pywsgi.WSGIServer(
        listener=('0.0.0.0', 5000),
        application=app,
        handler_class=WebSocketHandler)
    server.serve_forever()


if __name__ == '__main__':
    run_server()
