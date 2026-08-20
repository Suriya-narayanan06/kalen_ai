import sqlite3
from pathlib import Path

class Database:

    def __init__(self, db_name="kalen.db"):

        self.db = sqlite3.connect(db_name)

        self.cursor = self.db.cursor()

        self.create_tables()

    def create_tables(self):

        self.cursor.execute("""
        CREATE TABLE IF NOT EXISTS memory(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user TEXT,
            assistant TEXT,
            time TEXT
        )
        """)

        self.cursor.execute("""
        CREATE TABLE IF NOT EXISTS preferences(
            key TEXT PRIMARY KEY,
            value TEXT
        )
        """)

        self.cursor.execute("""
        CREATE TABLE IF NOT EXISTS plugins(
            name TEXT PRIMARY KEY,
            version TEXT,
            enabled INTEGER
        )
        """)

        self.cursor.execute("""
        CREATE TABLE IF NOT EXISTS automation(
            id TEXT PRIMARY KEY,
            title TEXT,
            trigger TEXT,
            action TEXT
        )
        """)

        self.db.commit()

    def save_memory(self,user,assistant,time):

        self.cursor.execute(
        "INSERT INTO memory(user,assistant,time) VALUES(?,?,?)",
        (user,assistant,time)
        )

        self.db.commit()

    def memories(self):

        self.cursor.execute(
        "SELECT * FROM memory"
        )

        return self.cursor.fetchall()

    def set_preference(self,key,value):

        self.cursor.execute("""
        INSERT OR REPLACE INTO preferences
        VALUES(?,?)
        """,(key,value))

        self.db.commit()

    def get_preference(self,key):

        self.cursor.execute("""
        SELECT value FROM preferences
        WHERE key=?
        """,(key,))

        row=self.cursor.fetchone()

        return row[0] if row else None

    def close(self):

        self.db.close()