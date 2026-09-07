# Local backend setup

The project is currently verified with SQLite on Windows. PostgreSQL is
optional until it is installed and a database/password are available.

```powershell
cd "D:\Downloads\GauRakshak_project_docs 2\backend"
python -m venv venv
.\venv\Scripts\Activate.ps1
python -m pip install -r requirements.txt
python create_tables.py
python test_db.py
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

Verified local endpoints:

- `GET http://127.0.0.1:8000/health`
- `GET http://127.0.0.1:8000/docs`
- `POST /auth/verify-otp`
- `GET /cows`
- `GET /cows/sample-data?cow_id=COW-022`

## PostgreSQL

After installing PostgreSQL and creating the database, put this in the ignored
`backend/.env` file, replacing the password locally:

```text
DATABASE_URL=postgresql+psycopg://postgres:YOUR_PASSWORD@localhost:9856/mastitis_db
```

Then rerun `create_tables.py` and `test_db.py`. Never commit `.env` or share a
connection string containing a password.
