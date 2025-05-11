# gemini_cli/cli.py
import argparse
import sys
import shutil
import textwrap
import logging
from .main import generate_text

# Configure logger for this module
logger = logging.getLogger(__name__)

class AnsiColors:
    RED = "\033[91m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    BOLD = "\033[1m"
    RESET = "\033[0m"


def safe_print(text: str) -> None:
    """
    Print text to the console without breaking words across lines.
    If a word exceeds the terminal width, pad it with spaces to fit.
    """
    # Determine terminal width, fallback to 80
    try:
        width = shutil.get_terminal_size().columns
    except Exception:
        width = 80

    # Prepare a TextWrapper that doesn't break long words or hyphens
    wrapper = textwrap.TextWrapper(width=width, break_long_words=False, break_on_hyphens=False)

    # Pre-process text: pad any word longer than width
    def pad_long_words(s: str) -> str:
        parts = []
        for word in s.split():
            if len(word) > width:
                # pad with spaces to exact width
                parts.append(word + " " * (width - len(word)))
            else:
                parts.append(word)
        return " ".join(parts)

    padded = pad_long_words(text)
    lines = wrapper.wrap(padded)

    for line in lines:
        print(line)


def main():
    parser = argparse.ArgumentParser(
        description="Terminal client for Gemini AI interactions."
    )
    parser.add_argument(
        "prompt",
        type=str,
        help="The prompt to send to Gemini AI."
    )
    parser.add_argument(
        "-t", "--temperature",
        type=float,
        default=0.7,
        help="Controls randomness of output. Range: 0.0 to 2.0. (default: 0.7)"
    )
    parser.add_argument(
        "-m", "--model",
        type=str,
        default="gemini-2.0-flash",
        help="The Gemini AI model to use. (default: gemini-2.0-flash)"
    )
    parser.add_argument(
        "-o", "--max-output",
        type=int,
        default=2048,
        help="Maximum number of output tokens. (default: 2048)"
    )

    if len(sys.argv) == 1:
        parser.print_help(sys.stderr)
        sys.exit(1)

    args = parser.parse_args()

    # Validate arguments
    if not (0.0 <= args.temperature <= 2.0):
        print(f"{AnsiColors.RED}{AnsiColors.BOLD}Error: Temperature must be between 0.0 and 2.0.{AnsiColors.RESET}")
        sys.exit(1)

    if args.max_output <= 0:
        print(f"{AnsiColors.RED}{AnsiColors.BOLD}Error: Maximum output tokens must be positive.{AnsiColors.RESET}")
        sys.exit(1)

    # Notify user
    print(f"{AnsiColors.YELLOW}Generating response...{AnsiColors.RESET}\n")

    try:
        response_text = generate_text(
            prompt=args.prompt,
            temperature=args.temperature,
            max_out=args.max_output,
            ai_model=args.model
        )
    except Exception as e:
        logger.error("Failed to generate text: %s", e)
        print(f"{AnsiColors.RED}{AnsiColors.BOLD}Error: {e}{AnsiColors.RESET}")
        sys.exit(1)

    # Print the response safely
    safe_print(response_text)


if __name__ == "__main__":
    main()
