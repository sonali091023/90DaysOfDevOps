import os

class Config:
    SECRET_KEY = os.environ.get("SECRET_KEY", "dev-secret")
    SQLALCHEMY_DATABASE_URI = os.environ.get("DATABASE_URL", "postgresql://user:password@db:5432/jiohotstar")
    SQLALCHEMY_TRACK_MODIFICATIONS = False
