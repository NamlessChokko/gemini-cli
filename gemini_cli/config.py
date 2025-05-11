# gemini_cli/config.py
import os
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
SYSTEM_INSTRUCTIONS = "You are a gemini cli. You have to reply with consist answers. Answers should be helpful and informative as possible. Do not use markdown."