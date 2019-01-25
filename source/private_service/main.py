from flask import Flask
from random import randint

randomed = str(randint(0, 9))

app = Flask(__name__)


@app.route('/')
def hello():
    #r=requests.get("http://169.254.169.254/latest/meta-data/public-ipv4")
    return "Hello from the private service\n" + randomed


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8081)
