"""Smoke test cho các endpoint mới: wishlist, orders, reviews, notifications, profile, filters."""
import os
import sys
import uuid

BACKEND_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(BACKEND_DIR)
sys.path.insert(0, BACKEND_DIR)
os.environ["DATABASE_URL"] = "sqlite:///./smoke_test2.db"
if os.path.exists("smoke_test2.db"):
    os.remove("smoke_test2.db")

from fastapi.testclient import TestClient  # noqa: E402
import main  # noqa: E402

failures = []


def check(name, cond, extra=""):
    print(("PASS " if cond else "FAIL ") + name + (f" -> {extra}" if extra and not cond else ""))
    if not cond:
        failures.append(name)


with TestClient(main.app) as c:
    email = f"u{uuid.uuid4().hex[:8]}@test.vn"
    r = c.post("/api/auth/register", json={"email": email, "password": "secret123", "username": "Người Test"})
    check("register", r.status_code == 200, r.text)

    r = c.post("/api/auth/login", json={"email": email, "password": "secret123"})
    token = r.json()["data"]["accessToken"]
    h = {"Authorization": f"Bearer {token}"}

    # --- Notifications: welcome ---
    r = c.get("/api/notifications", headers=h)
    d = r.json()["data"]
    check("welcome notification", r.status_code == 200 and d["total"] == 1 and d["unreadCount"] == 1, r.text)
    noti_id = d["items"][0]["id"]

    r = c.get("/api/notifications/unread-count", headers=h)
    check("unread-count", r.json()["data"]["unreadCount"] == 1, r.text)

    r = c.post(f"/api/notifications/{noti_id}/read", headers=h)
    check("mark read", r.status_code == 200 and r.json()["data"]["isRead"] is True, r.text)
    check("unread now 0", c.get("/api/notifications/unread-count", headers=h).json()["data"]["unreadCount"] == 0)

    # --- Catalog facets & filters ---
    r = c.get("/api/games/facets", headers=h)
    fac = r.json()["data"]
    check("facets genres", "RPG" in fac["genres"] and "android" in fac["platforms"], r.text)

    r = c.get("/api/games", headers=h, params={"priceType": "free"})
    items = r.json()["data"]["items"]
    check("filter free", len(items) == 3 and all(i["pricing"]["type"] == "free" for i in items), r.text)

    r = c.get("/api/games", headers=h, params={"genre": ["RPG"]})
    check("filter genre RPG", r.json()["data"]["total"] == 2, r.text)

    r = c.get("/api/games", headers=h, params={"genre": ["RPG", "Casual"]})
    check("filter 2 genres AND", r.json()["data"]["total"] == 0, r.text)

    r = c.get("/api/games", headers=h, params={"sort": "price_desc"})
    prices = [i["pricing"]["price"] or 0 for i in r.json()["data"]["items"]]
    check("sort price_desc", prices == sorted(prices, reverse=True), str(prices))

    r = c.get("/api/games", headers=h, params={"sort": "newest"})
    check("sort newest = game_1", r.json()["data"]["items"][0]["id"] == "game_1", r.text)

    r = c.get("/api/games", headers=h, params={"minPrice": 100000, "maxPrice": 150000})
    check("price range", [i["id"] for i in r.json()["data"]["items"]] == ["game_1"], r.text)

    r = c.get("/api/games", headers=h, params={"sort": "bogus"})
    check("invalid sort 400", r.status_code == 400 and r.json()["detail"]["code"] == "CATALOG_002", r.text)

    r = c.get("/api/games", headers=h, params={"platform": "switch"})
    check("unknown platform empty", r.json()["data"]["total"] == 0, r.text)

    # --- Wishlist ---
    r = c.post("/api/wishlist/game_3", headers=h)
    check("wishlist add", r.status_code == 200, r.text)
    r = c.post("/api/wishlist/game_3", headers=h)
    check("wishlist add idempotent", r.status_code == 200, r.text)
    r = c.get("/api/wishlist", headers=h)
    check("wishlist list", [g["id"] for g in r.json()["data"]] == ["game_3"], r.text)
    r = c.get("/api/games/game_3", headers=h)
    check("wishlisted flag", r.json()["data"]["ownership"]["wishlisted"] is True, r.text)
    r = c.post("/api/wishlist/nope", headers=h)
    check("wishlist 404", r.status_code == 404, r.text)

    # --- Library: free only ---
    r = c.post("/api/library/game_1", headers=h)
    check("paid game rejected from library", r.status_code == 402 and r.json()["detail"]["code"] == "LIB_001", r.text)
    r = c.post("/api/library/game_2", headers=h)
    check("free game added", r.status_code == 200, r.text)

    # --- Download url gating ---
    r = c.get("/api/games/game_2/download-url", headers=h)
    check("download owned ok", r.status_code == 200 and r.json()["data"]["url"].endswith("game_2.pkg"), r.text)
    r = c.get("/api/games/game_5/download-url", headers=h)
    check("download unowned 403", r.status_code == 403 and r.json()["detail"]["code"] == "DL_001", r.text)

    # --- Orders ---
    r = c.post("/api/orders", headers=h, json={"gameId": "game_3", "paymentMethod": "momo"})
    check("buy paid game", r.status_code == 200 and r.json()["data"]["amount"] == 210000, r.text)
    order_id = r.json()["data"]["id"]

    r = c.get("/api/games/game_3", headers=h)
    own = r.json()["data"]["ownership"]
    check("owned after purchase & wishlist cleared", own["owned"] is True and own["wishlisted"] is False, r.text)

    r = c.post("/api/orders", headers=h, json={"gameId": "game_3"})
    check("buy twice 409", r.status_code == 409 and r.json()["detail"]["code"] == "ORDER_001", r.text)
    r = c.post("/api/orders", headers=h, json={"gameId": "game_2"})
    check("buy free 400/409", r.status_code in (400, 409), r.text)
    r = c.post("/api/orders", headers=h, json={"gameId": "game_5", "paymentMethod": "bitcoin"})
    check("bad payment method 400", r.status_code == 400 and r.json()["detail"]["code"] == "ORDER_003", r.text)

    r = c.get("/api/orders", headers=h)
    check("order history", r.json()["data"]["total"] == 1, r.text)
    r = c.get(f"/api/orders/{order_id}", headers=h)
    check("order detail", r.json()["data"]["gameName"] == "Vương Quốc Sụp Đổ", r.text)
    r = c.get("/api/orders/order_nope", headers=h)
    check("order 404", r.status_code == 404, r.text)

    r = c.get("/api/notifications", headers=h, params={"unreadOnly": True})
    d = r.json()["data"]
    check("order notification", d["unreadCount"] == 1 and d["items"][0]["type"] == "order", r.text)

    # --- Reviews ---
    r = c.post("/api/games/game_5/reviews", headers=h, json={"rating": 5})
    check("review unowned 403", r.status_code == 403 and r.json()["detail"]["code"] == "REVIEW_001", r.text)
    r = c.post("/api/games/game_3/reviews", headers=h, json={"rating": 6})
    check("rating > 5 rejected", r.status_code == 422, r.text)
    r = c.post("/api/games/game_3/reviews", headers=h, json={"rating": 4, "comment": "Hay!"})
    check("create review", r.status_code == 200 and r.json()["data"]["mine"] is True, r.text)
    r = c.post("/api/games/game_3/reviews", headers=h, json={"rating": 5, "comment": "Chơi lại thấy hay hơn"})
    check("upsert review", r.status_code == 200 and r.json()["data"]["rating"] == 5, r.text)
    r = c.get("/api/games/game_3/reviews", headers=h)
    d = r.json()["data"]
    check("review list single", d["total"] == 1 and d["summary"]["average"] == 5.0, r.text)
    r = c.get("/api/games/game_3", headers=h)
    check("rating in game detail", r.json()["data"]["rating"] == {"average": 5.0, "count": 1}, r.text)
    r = c.get("/api/games", headers=h, params={"sort": "rating_desc"})
    check("sort rating_desc", r.json()["data"]["items"][0]["id"] == "game_3", r.text)
    r = c.delete("/api/games/game_3/reviews/me", headers=h)
    check("delete review", r.status_code == 200, r.text)
    r = c.delete("/api/games/game_3/reviews/me", headers=h)
    check("delete review twice 404", r.status_code == 404, r.text)

    # --- Profile ---
    r = c.patch("/api/users/me", headers=h, json={"displayName": "Võ Thiện", "bio": "Game thủ"})
    d = r.json()["data"]
    check("patch profile", d["displayName"] == "Võ Thiện" and d["bio"] == "Game thủ", r.text)
    r = c.patch("/api/users/me", headers=h, json={"avatarUrl": "https://x/y.png"})
    d = r.json()["data"]
    check("patch partial keeps name", d["displayName"] == "Võ Thiện" and d["avatarUrl"] == "https://x/y.png", r.text)
    r = c.patch("/api/users/me", headers=h, json={"displayName": ""})
    check("empty name 422", r.status_code == 422, r.text)

    r = c.post("/api/users/me/password", headers=h, json={"currentPassword": "wrong", "newPassword": "newpass1"})
    check("wrong current password", r.status_code == 400 and r.json()["detail"]["code"] == "AUTH_006", r.text)
    r = c.post("/api/users/me/password", headers=h, json={"currentPassword": "secret123", "newPassword": "secret123"})
    check("same password rejected", r.status_code == 400 and r.json()["detail"]["code"] == "AUTH_007", r.text)
    r = c.post("/api/users/me/password", headers=h, json={"currentPassword": "secret123", "newPassword": "abc"})
    check("short password 422", r.status_code == 422, r.text)
    r = c.post("/api/users/me/password", headers=h, json={"currentPassword": "secret123", "newPassword": "newpass1"})
    check("change password", r.status_code == 200, r.text)
    check("old password fails", c.post("/api/auth/login", json={"email": email, "password": "secret123"}).status_code == 401)
    check("new password works", c.post("/api/auth/login", json={"email": email, "password": "newpass1"}).status_code == 200)

    # --- Cross-user isolation ---
    email2 = f"u{uuid.uuid4().hex[:8]}@test.vn"
    c.post("/api/auth/register", json={"email": email2, "password": "secret123", "username": "Khác"})
    t2 = c.post("/api/auth/login", json={"email": email2, "password": "secret123"}).json()["data"]["accessToken"]
    h2 = {"Authorization": f"Bearer {t2}"}
    check("other user no orders", c.get("/api/orders", headers=h2).json()["data"]["total"] == 0)
    check("other user cannot read order", c.get(f"/api/orders/{order_id}", headers=h2).status_code == 404)
    check("other user cannot read noti", c.post(f"/api/notifications/{noti_id}/read", headers=h2).status_code == 404)
    check("other user empty wishlist", c.get("/api/wishlist", headers=h2).json()["data"] == [])

    # --- Auth required ---
    for path in ["/api/wishlist", "/api/orders", "/api/notifications", "/api/games/facets"]:
        check(f"401 without token {path}", c.get(path).status_code == 401)

os.remove(os.path.join(BACKEND_DIR, "smoke_test2.db"))
print("\n" + ("ALL PASSED" if not failures else f"{len(failures)} FAILURES: {failures}"))
sys.exit(1 if failures else 0)
