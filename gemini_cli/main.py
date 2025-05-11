# gemini_cli/main.py
from google import genai
from google.genai import types
from .config import GOOGLE_API_KEY, SYSTEM_INSTRUCTIONS

def generate_text(prompt: str, temperature: float = 0.7, max_out: int = 2048, ai_model: str = "gemini-2.0-flash") -> str:
    """
    Generates text using the Gemini API based on the provided prompt and configuration.

    Args:
        prompt (str): The input text prompt to guide the text generation.
        temperature (float, optional): Controls the randomness of the output. 
            Higher values (e.g., 1.0) produce more random results, while lower values (e.g., 0.2) make the output more focused and deterministic. Defaults to 0.7.
        max_out (int, optional): The maximum number of tokens to generate in the output. Defaults to 2048.
        ai_model (str, optional): The name of the AI model to use for text generation. Defaults to "gemini-2.0-flash".

    Returns:
        str: The generated text if successful, or an error message if the generation fails.

    Notes:
        - Requires a valid `GOOGLE_API_KEY` to communicate with the Gemini API.
        - Handles exceptions during API communication and provides error messages for debugging.
        - If the API response contains no valid content, an appropriate message is returned.
    """
    if not GOOGLE_API_KEY:
        return "Error: API key is not configured."

    try:
        client = genai.Client(api_key=GOOGLE_API_KEY)

        response = client.models.generate_content(
            model=ai_model,
            contents=prompt,
            config=types.GenerateContentConfig(
                max_output_tokens=max_out,
                temperature=temperature,
                system_instruction=SYSTEM_INSTRUCTIONS,
            ),
        )

        try:
            candidates = response.candidates
            if candidates:
                parts = candidates[0].content.parts if candidates[0].content and candidates[0].content.parts else None
                if parts and hasattr(parts[0], 'text'):
                    return parts[0].text or "" 
        except Exception:
            pass


        if hasattr(response, 'prompt_feedback') and response.prompt_feedback:
            return f"Could not generate a response. Reason: {response.prompt_feedback}"
        else:
            return "Could not generate a response. No specific reason provided by the API, or the content was empty/malformed."

    except Exception as e:
        return f"Error communicating with the Gemini API: {e}"
