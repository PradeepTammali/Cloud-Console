
import logging


log = logging.getLogger('cloud_console')
log.setLevel(logging.DEBUG)
fh = logging.FileHandler('/tmp/cloud_console.log')
fh.setFormatter(logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s'))

ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
ch.setFormatter(logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
log.addHandler(ch)
