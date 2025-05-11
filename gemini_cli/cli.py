# gemini_cli/cli.py
import argparse
import sys
from .main import generate_text

class AnsiColors:
    RED = "\033[91m"
    GREEN = "\033[92m"
    RESET = "\033[0m"
    BOLD = "\033[1m"
    YELLOW = "\033[93m"

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
        help="Controls the randomness of the output. Range: 0.0 to 2.0. (default: 0.7)"
    )
    parser.add_argument(
        "-m", "--model",
        type=str,
        default="gemini-1.5-flash",
        help="The Gemini AI model to use. (default: gemini-1.5-flash)"
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

    if not 0.0 <= args.temperature <= 2.0:
        print(f"{AnsiColors.RED}{AnsiColors.BOLD}Error: Temperature must be between 0.0 and 2.0.{AnsiColors.RESET}", end="")
        sys.exit(1)

    if args.max_output <= 0:
        print(f"{AnsiColors.RED}{AnsiColors.BOLD}Error: Maximum output tokens must be a positive integer.{AnsiColors.RESET}", end="")
        sys.exit(1)

    print(f"{AnsiColors.YELLOW}Generating response...{AnsiColors.RESET}\n", end="") # Opcional: colorear el mensaje de "generando"
    
    response_text = generate_text(
        prompt=args.prompt,
        temperature=args.temperature,
        max_out=args.max_output,
        ai_model=args.model
    )

    if response_text.startswith("Error:") or "Could not generate a response" in response_text:
        print(f"{AnsiColors.RED}{AnsiColors.BOLD}{response_text}{AnsiColors.RESET}", end="")
    else:
        print(response_text, end="") 

if __name__ == "__main__":
    main()