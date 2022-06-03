from flask import Flask, jsonify
import time, socket

app = Flask(__name__)

@app.route('/timestamp')
def get_timestamp():
    mytime = time.time()
    return jsonify(mytime)
@app.route('/hostname')
def get_hostname():
    myhost = socket.gethostname()
    return jsonify(myhost)

if __name__ == "__main__":
    app.run(debug=False)