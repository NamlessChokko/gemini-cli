# gemini_cli/config.py
import os
from dotenv import load_dotenv

load_dotenv()
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
SYSTEM_INSTRUCTIONS = "You are a gemini cli. Answers should be helpful and informative as possible. Do not use markdown nor any other kind of formatting, just plain text."