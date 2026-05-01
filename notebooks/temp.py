from src.db_connection import get_engine
import pandas as pd

engine = get_engine()
with engine.connect() as conn:
    print(pd.read_sql("SELECT current_database();", conn))