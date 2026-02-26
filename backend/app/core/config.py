from functools import lru_cache

from pydantic import Field
from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = Field(default="Secure Vibe API", alias="APP_NAME")
    env: str = Field(default="dev", alias="ENV")
    debug: bool = Field(default=False, alias="DEBUG")
    api_v1_prefix: str = Field(default="/api/v1", alias="API_V1_PREFIX")

    database_url: str = Field(default="sqlite:///./secure_vibe.db", alias="DATABASE_URL")
    require_https: bool = Field(default=False, alias="REQUIRE_HTTPS")

    jwt_algorithm: str = Field(default="HS256", alias="JWT_ALGORITHM")
    jwt_access_token_expire_minutes: int = Field(default=30, alias="JWT_ACCESS_TOKEN_EXPIRE_MINUTES")
    jwt_refresh_token_expire_minutes: int = Field(default=60 * 24 * 7, alias="JWT_REFRESH_TOKEN_EXPIRE_MINUTES")
    jwt_secret_key: str = Field(default="unsafe-dev-secret", alias="JWT_SECRET_KEY")

    cors_origins: str = Field(default="http://localhost:3000", alias="CORS_ORIGINS")
    rate_limit_requests: int = Field(default=120, alias="RATE_LIMIT_REQUESTS")
    rate_limit_window_seconds: int = Field(default=60, alias="RATE_LIMIT_WINDOW_SECONDS")

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", case_sensitive=False)

    @property
    def cors_origin_list(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]

    @model_validator(mode="after")
    def validate_security_settings(self) -> "Settings":
        env = self.env.lower().strip()

        if env in {"staging", "prod", "production"}:
            if len(self.jwt_secret_key) < 32 or self.jwt_secret_key == "unsafe-dev-secret":
                raise ValueError("JWT_SECRET_KEY must be at least 32 chars and non-default outside dev.")

            if "*" in self.cors_origin_list:
                raise ValueError("CORS_ORIGINS cannot contain '*' outside dev.")

            if self.debug:
                raise ValueError("DEBUG must be false outside dev.")

            if self.database_url.startswith("sqlite"):
                raise ValueError("DATABASE_URL must not use sqlite outside dev.")

            if not self.require_https:
                raise ValueError("REQUIRE_HTTPS must be true outside dev.")

        return self


@lru_cache
def get_settings() -> Settings:
    return Settings()
