import sys
from pathlib import Path

import uvicorn

# The application is a package (`app`), so the repository root must be on
# sys.path no matter which directory this script is launched from.
PROJECT_ROOT = Path(__file__).resolve().parent.parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from app.config import APP_PORT, APP_HOST, DEBUG


if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host= APP_HOST,
        port=APP_PORT,
        reload=DEBUG
        )
