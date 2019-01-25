import os
from flask import Flask

app = Flask(__name__)
import requests

private_service_namespace = os.environ.get('PRIVATE_SERVICE', 'private_service')


@app.route('/')
def hello():
    r = requests.get('http://' + private_service_namespace + ':8081')

    return "Hello from the public service and " + r.text


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
