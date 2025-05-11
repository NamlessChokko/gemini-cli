# gemini_cli/main.py

import logging
from typing import Optional

from google.genai import Client, types

from .config import GOOGLE_API_KEY, SYSTEM_INSTRUCTIONS

# Configure logger for this module
logger = logging.getLogger(__name__)


def generate_text(
    prompt: str,
    temperature: float = 0.7,
    max_out: int = 2048,
    ai_model: str = "gemini-2.0-flash",
) -> str:
    """
    Generate text via the Gemini API.

    Args:
        prompt (str): The text prompt to send to the model.
        temperature (float): Sampling temperature (higher -> more random). Default: 0.7.
        max_out (int): Maximum number of tokens to generate. Default: 2048.
        ai_model (str): Model identifier. Default: "gemini-2.0-flash".

    Returns:
        str: The generated text.

    Raises:
        RuntimeError: If API key is missing or communication fails.
        ValueError: If the API responds with no usable content.
    """
    if not GOOGLE_API_KEY:
        raise RuntimeError("API key is not configured. Please set GOOGLE_API_KEY in your config.")

    try:
        client = Client(api_key=GOOGLE_API_KEY)
        config = types.GenerateContentConfig(
            max_output_tokens=max_out,
            temperature=temperature,
            system_instruction=SYSTEM_INSTRUCTIONS,
        )

        response = client.models.generate_content(
            model=ai_model,
            contents=prompt,
            config=config,
        )

        # Extract first candidate text
        text = _extract_first_text(response)
        if text is not None:
            return text

        # If no text found, maybe there is feedback explaining why
        if getattr(response, "prompt_feedback", None):
            raise ValueError(f"Generation failed: {response.prompt_feedback}")

        raise ValueError("Generation failed: no content returned by the API.")

    except Exception as e:
        # Log full exception for debugging, then re-raise as RuntimeError
        logger.exception("Error while calling Gemini API")
        raise RuntimeError(f"Error communicating with Gemini API: {e}") from e


def _extract_first_text(response) -> Optional[str]:
    """
    Helper to pull out the first chunk of text from the API response.
    Returns None if no valid text is found.
    """
    try:
        candidates = getattr(response, "candidates", None)
        if not candidates:
            return None

        candidate = candidates[0]
        content = getattr(candidate, "content", None)
        parts = getattr(content, "parts", None) if content else None

        if parts and len(parts) > 0 and hasattr(parts[0], "text"):
            return parts[0].text or ""

    except Exception:
        # In case the API shape changed, we log and return None
        logger.debug("Failed to extract text from response", exc_info=True)

    return None
