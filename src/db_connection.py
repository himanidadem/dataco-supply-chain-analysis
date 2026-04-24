"""Database connection utility."""
import os
from dotenv import load_dotenv
from sqlalchemy import create_engine

load_dotenv()

def get_engine():
    """Return SQLAlchemy engine for the dataco database."""
    user = os.getenv('DB_USER')
    password = os.getenv('DB_PASSWORD')
    host = os.getenv('DB_HOST')
    port = os.getenv('DB_PORT')
    name = os.getenv('DB_NAME')
    
    url = f'postgresql+psycopg2://{user}:{password}@{host}:{port}/{name}'
    return create_engine(url)