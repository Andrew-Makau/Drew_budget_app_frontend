
# 📋 Budget App 7-Day Project Plan (Flutter + Flask)

## **Day 1 – Setup & Architecture**
- Define requirements:  
  - ✅ Features: signup/login, add expenses/income, categorize, monthly summary, export (CSV/PDF).  
  - ❌ Skip for MVP: bank API, AI recommendations.  
- Tech setup:  
  - Backend: Flask (or FastAPI).  
  - Database: SQLite (upgrade later to PostgreSQL).  
  - Frontend: Flutter (with Provider/Riverpod).  
- DevOps: GitHub repo, CI/CD (GitHub Actions + deploy to Render/Heroku).  

---

## **Day 2 – Backend MVP**
- User authentication (JWT-based).  
- Models: User, Transaction, Category.  
- REST API endpoints:  
  - `POST /auth/signup`  
  - `POST /auth/login`  
  - `GET /transactions`  
  - `POST /transactions`  
- Tools: Flask-JWT-Extended, SQLAlchemy, Swagger/OpenAPI docs.  

---

## **Day 3 – Flutter UI Basics**
- Pages: Login, Signup, Dashboard, Add Transaction.  
- Tools: dio (API calls), flutter_secure_storage (JWT), Riverpod/Provider.  
- Build mock UI with static data first.  

---

## **Day 4 – Connect Backend & Frontend**
- Integrate Flutter with Flask API.  
- Test signup/login and persist JWT.  
- Display user transactions in Dashboard.  
- Add new transaction → POST to backend.  
- Debug CORS (Flask-CORS).  

---

## **Day 5 – Analytics & Extras**
- Backend: monthly summary endpoint (group by category/date).  
- Frontend:  
  - Use charts_flutter or Syncfusion charts for expenses.  
  - Add filter by month/year.  

---

## **Day 6 – Polish & Export**
- Backend: add export endpoint (`/export/csv`, optional PDF).  
- Frontend:  
  - Improve UI (icons, colors).  
  - Input validation & error handling.  

---

## **Day 7 – Testing & Deployment**
- Write tests (pytest for Flask, flutter_test for Flutter).  
- Deploy Flask to Render/Heroku.  
- Deploy Flutter app (APK or TestFlight).  
- Final demo run with dummy users & transactions.  

---

# 🚀 Tools & Techniques Recommendations
- Backend: Flask (simple), FastAPI (alternative).  
- Database: SQLite (MVP), PostgreSQL (production).  
- Frontend: Flutter with Riverpod + Dio.  
- Design prototyping: **Lovable.dev** (UI mockups), **Bolt.new** (auto-generate logic in TypeScript).  
- Deployment: Render/Railway/Heroku for backend, Play Store/TestFlight for frontend.  

---

