from flask import Blueprint, request, jsonify #,render_template
from flask_bcrypt import Bcrypt
from flask_login import login_user, logout_user
from models import db, User

auth_bp = Blueprint("auth", __name__)
bcrypt = Bcrypt()

# -------------------------
# PAGE ROUTES (GET)
# -------------------------

#@auth_bp.route("/register", methods=["GET"])def register_page():return render_template("register.html")

#@auth_bp.route("/login", methods=["GET"])def login_page():return render_template("login.html")


# -------------------------
# API ROUTES (POST)
# -------------------------

@auth_bp.route("/register", methods=["POST"])
def register():
    data = request.json
    hashed = bcrypt.generate_password_hash(data["password"]).decode("utf-8")
    user = User(email=data["email"], password=hashed)
    db.session.add(user)
    db.session.commit()
    return jsonify({"message": "Registered successfully"}), 201


@auth_bp.route("/login", methods=["POST"])
def login():
    data = request.json
    user = User.query.filter_by(email=data["email"]).first()

    if user and bcrypt.check_password_hash(user.password, data["password"]):
        login_user(user)
        return jsonify({
            "message": "Login successful",
            "plan": user.plan
        })

    return jsonify({"error": "Invalid credentials"}), 401


@auth_bp.route("/logout")
def logout():
    logout_user()
    return jsonify({"message": "Logged out"})
