python -m venv venv
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

pip install -r requirements.txt

# running  
`conda create -n gamesmgr python=3.11 pip -y`
`conda activate gamesmgr`
`uvicorn main:app --reload --host 0.0.0.0 --port 8000`
`flutter run --dart-define=USE_MOCK=false --dart-define=API_BASE_URL=http://127.0.0.1:8000`
>@cre Tiến Thiện