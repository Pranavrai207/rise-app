from __future__ import annotations

from fastapi import FastAPI, HTTPException, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse


def _http_code_name(status_code: int) -> str:
    mapping = {
        status.HTTP_400_BAD_REQUEST: "bad_request",
        status.HTTP_401_UNAUTHORIZED: "unauthorized",
        status.HTTP_403_FORBIDDEN: "forbidden",
        status.HTTP_404_NOT_FOUND: "not_found",
        status.HTTP_409_CONFLICT: "conflict",
        status.HTTP_422_UNPROCESSABLE_ENTITY: "validation_error",
        status.HTTP_429_TOO_MANY_REQUESTS: "rate_limited",
        status.HTTP_500_INTERNAL_SERVER_ERROR: "internal_error",
    }
    return mapping.get(status_code, f"http_{status_code}")


def register_exception_handlers(app: FastAPI) -> None:
    @app.exception_handler(HTTPException)
    async def handle_http_exception(_: Request, exc: HTTPException) -> JSONResponse:
        message = exc.detail if isinstance(exc.detail, str) else _http_code_name(exc.status_code)
        return JSONResponse(
            status_code=exc.status_code,
            content={"code": _http_code_name(exc.status_code), "message": message},
        )

    @app.exception_handler(RequestValidationError)
    async def handle_validation_exception(_: Request, __: RequestValidationError) -> JSONResponse:
        return JSONResponse(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            content={"code": "validation_error", "message": "Invalid request payload."},
        )

    @app.exception_handler(Exception)
    async def handle_unexpected_exception(_: Request, __: Exception) -> JSONResponse:
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={"code": "internal_error", "message": "Internal server error."},
        )
