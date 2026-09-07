"""Central configuration, loaded from environment / .env.

Secrets NEVER live in code — they come from the environment. See SECURITY.md.
"""
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_env: str = "development"
    api_host: str = "0.0.0.0"
    api_port: int = 8000

    database_url: str = "sqlite:///./gaurakshak.db"

    # Development may use the explicit fallback below. Production must set a
    # strong value through JWT_SECRET_KEY; main.py refuses to start otherwise.
    jwt_secret_key: str = "dev-only-insecure-secret-change-me"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 1440

    gausaathi_llm_api_key: str = ""

    # A fixed OTP is convenient for a local demo only. Set this false in every
    # deployed environment and connect a real SMS OTP provider.
    demo_auth_enabled: bool = True

    cors_origins: str = "http://localhost,http://localhost:3000,http://localhost:8080,http://127.0.0.1:8080"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @property
    def cors_origin_list(self) -> list[str]:
        configured = [o.strip() for o in self.cors_origins.split(",") if o.strip()]
        local_origins = ["http://localhost:8080", "http://127.0.0.1:8080"]
        return list(dict.fromkeys(configured + local_origins))

    @property
    def cors_origin_regex(self) -> str | None:
        """Allow Flutter's changing local web port during development only."""
        if self.app_env.lower() in {"development", "dev", "local"}:
            return r"^https?://(localhost|127\.0\.0\.1)(:\d+)?$"
        return None


settings = Settings()
