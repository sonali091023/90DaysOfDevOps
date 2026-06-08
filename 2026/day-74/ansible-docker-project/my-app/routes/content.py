from flask import Blueprint, jsonify, request
from models import Content

content_bp = Blueprint("content", __name__)

@content_bp.route("/content")
def get_content():
    category = request.args.get("category")
    query = Content.query
    if category:
        query = query.filter_by(category=category)
    items = query.all()
    return jsonify([{
        "id": c.id, "title": c.title,
        "category": c.category, "badge": c.badge,
        "language": c.language, "is_premium": c.is_premium
    } for c in items])
