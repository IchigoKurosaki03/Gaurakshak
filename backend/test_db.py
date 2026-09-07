"""Verify the configured database connection without printing credentials.

Run from backend/: ``venv\\Scripts\\python test_db.py``.
The same script works for the local SQLite fallback and PostgreSQL.
"""
from sqlalchemy import inspect, text

from app.config import settings
from app.database import engine


def main() -> None:
    with engine.connect() as connection:
        dialect = connection.dialect.name
        version = connection.execute(text("select sqlite_version()" if dialect == "sqlite" else "select version()" )).scalar_one()
        tables = sorted(inspect(connection).get_table_names())

    print(f"Database connection successful ({dialect}).")
    print(f"Database version: {version}")
    print(f"Configured tables: {', '.join(tables) if tables else '(none)'}")


if __name__ == "__main__":
    main()
