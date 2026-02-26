
import sqlite3
import os

db_path = "backend/secure_vibe.db"
if os.path.exists(db_path):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("PRAGMA table_info(avatar_states)")
    columns = [row[1] for row in cursor.fetchall()]
    print(f"Columns in avatar_states: {columns}")
    if "avatar_type" not in columns:
        print("Adding avatar_type column...")
        cursor.execute("ALTER TABLE avatar_states ADD COLUMN avatar_type VARCHAR(32) DEFAULT 'neutral'")
        conn.commit()
        print("Column added successfully.")
    else:
        print("avatar_type column already exists.")
    conn.close()
else:
    print(f"Database not found at {db_path}")
