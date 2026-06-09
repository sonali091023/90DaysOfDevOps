from flask_sqlalchemy import SQLAlchemy
from flask_login import UserMixin
from datetime import datetime

db = SQLAlchemy()

class User(UserMixin, db.Model):
    id          = db.Column(db.Integer, primary_key=True)
    email       = db.Column(db.String(120), unique=True, nullable=False)
    password    = db.Column(db.String(200), nullable=False)
    plan        = db.Column(db.String(20), default="free")  # free/super/premium
    created_at  = db.Column(db.DateTime, default=datetime.utcnow)

class Content(db.Model):
    id          = db.Column(db.Integer, primary_key=True)
    title       = db.Column(db.String(200), nullable=False)
    category    = db.Column(db.String(50))   # movies/sports/shows
    language    = db.Column(db.String(30))
    badge       = db.Column(db.String(20))   # Live/Free/HD
    is_premium  = db.Column(db.Boolean, default=False)
    thumbnail   = db.Column(db.String(300))

class Subscription(db.Model):
    id          = db.Column(db.Integer, primary_key=True)
    user_id     = db.Column(db.Integer, db.ForeignKey("user.id"))
    plan        = db.Column(db.String(20))
    start_date  = db.Column(db.DateTime, default=datetime.utcnow)
    end_date    = db.Column(db.DateTime)
