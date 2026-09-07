"""Create the SQLAlchemy tables for the configured database.

For production PostgreSQL, replace this one-shot bootstrap with migrations.
"""
from app.database import Base, engine
from app import models  # noqa: F401 - registers every model with Base


def main() -> None:
    print("Creating database tables...")
    Base.metadata.create_all(bind=engine)
    print("Database tables created successfully!")


if __name__ == "__main__":
    main()
