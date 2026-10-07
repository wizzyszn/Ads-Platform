import uvicorn

from config import APP_PORT, APP_HOST, DEBUG


if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host= APP_HOST,
        port=APP_PORT,
        reload=DEBUG
        )
