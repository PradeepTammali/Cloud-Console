import os
import threading
from utility.log import log
from kubernetes import client, config
from kubernetes.stream import stream


class KubernetesAPI(object):

    def __init__(self, api_server, id_token):
        kub_conf = client.Configuration()
        kub_conf.host = api_server
        kub_conf.verify_ssl = False
        kub_conf.api_key_prefix["authorization"] = "Bearer"
        kub_conf.api_key["authorization"] = id_token
        k8s_api_client = client.ApiClient(kub_conf)
        self.client_core_v1 = client.CoreV1Api(k8s_api_client)

    def __getattr__(self, item):
        if item in self.api_dict:
            return self.api_dict[item]
        if hasattr(client, item) and callable(getattr(client, item)):
            self.api_dict[item] = getattr(client, item)(
                api_client=self.api_client)
            return self.api_dict[item]


class K8SClient(KubernetesAPI):

    def __init__(self, api_server, id_token):
        super(K8SClient, self).__init__(api_server, id_token)

    def terminal_start(self, namespace, pod_name, container):
        command = [
            "/bin/sh",
            "-c",
            'TERM=xterm-256color; export TERM; [ -x /bin/bash ] '
            '&& ([ -x /usr/bin/script ] '
            '&& /usr/bin/script -q -c "/bin/bash" /dev/null || exec /bin/bash) '
            '|| exec /bin/sh']

        container_stream = stream(
            self.client_core_v1.connect_get_namespaced_pod_exec,
            name=pod_name,
            namespace=namespace,
            container=container,
            command=command,
            stderr=True, stdin=True,
            stdout=True, tty=True,
            _preload_content=False
        )

        return container_stream


class K8SStreamThread(threading.Thread):

    def __init__(self, ws, container_stream):
        super(K8SStreamThread, self).__init__()
        self.ws = ws
        self.stream = container_stream

    def run(self):
        while not self.ws.closed:

            if not self.stream.is_open():
                log.info('container stream closed')
                self.ws.close()

            try:
                if self.stream.peek_stdout():
                    stdout = self.stream.read_stdout()
                    self.ws.send(stdout)

                if self.stream.peek_stderr():
                    stderr = self.stream.read_stderr()
                    self.ws.send(stderr)
            except Exception as err:
                log.error('container stream err: {}'.format(err))
                self.ws.close()
                break
