#from flask import Flask, render_template

#app = Flask(__name__)

#@app.route("/")
#def home():
#    return render_template("index.html")

#if __name__ == "__main__":
#    app.run(host="0.0.0.0", port=5000)

#====================================================

from flask import Flask, render_template
from flask_login import LoginManager
from flask_bcrypt import Bcrypt
from config import Config
from models import db, User
from routes.auth import auth_bp
from routes.content import content_bp
from routes.subscription import sub_bp

app = Flask(__name__)
app.config.from_object(Config)

db.init_app(app)
bcrypt = Bcrypt(app)
login_manager = LoginManager(app)

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

app.register_blueprint(auth_bp, url_prefix="/auth")
app.register_blueprint(content_bp, url_prefix="/api")
app.register_blueprint(sub_bp, url_prefix="/api")

@app.route("/")
def home():
    return render_template("index.html")

if __name__ == "__main__":
    with app.app_context():
        db.create_all()
    app.run(host="0.0.0.0", port=5000)
