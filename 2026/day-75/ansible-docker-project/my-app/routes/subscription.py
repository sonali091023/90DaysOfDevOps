from flask import Blueprint, jsonify, request
from flask_login import login_required, current_user
from models import db, User, Subscription
from datetime import datetime, timedelta

sub_bp = Blueprint("subscription", __name__)

@sub_bp.route("/subscribe", methods=["POST"])
@login_required
def subscribe():
    data = request.json
    plan = data.get("plan")  # free / super / premium

    if plan not in ["free", "super", "premium"]:
        return jsonify({"error": "Invalid plan"}), 400

    # Set plan duration
    duration_days = 30  # 1 month for super/premium
    if plan == "free":
        duration_days = 36500  # effectively forever

    # Update user plan
    current_user.plan = plan
    db.session.commit()

    # Save subscription record
    subscription = Subscription(
        user_id=current_user.id,
        plan=plan,
        start_date=datetime.utcnow(),
        end_date=datetime.utcnow() + timedelta(days=duration_days)
    )
    db.session.add(subscription)
    db.session.commit()

    return jsonify({
        "message": f"Successfully subscribed to {plan} plan",
        "plan": plan,
        "expires": subscription.end_date.strftime("%Y-%m-%d")
    }), 200


@sub_bp.route("/my-plan", methods=["GET"])
@login_required
def my_plan():
    sub = Subscription.query.filter_by(user_id=current_user.id)\
            .order_by(Subscription.start_date.desc()).first()

    if not sub:
        return jsonify({"plan": "free", "expires": None})

    return jsonify({
        "plan": sub.plan,
        "start_date": sub.start_date.strftime("%Y-%m-%d"),
        "expires": sub.end_date.strftime("%Y-%m-%d")
    })


@sub_bp.route("/cancel", methods=["POST"])
@login_required
def cancel():
    current_user.plan = "free"
    db.session.commit()
    return jsonify({"message": "Subscription cancelled, reverted to free plan"})
