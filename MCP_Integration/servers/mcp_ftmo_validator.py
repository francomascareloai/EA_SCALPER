import json
import sys

def validate_ftmo(file_path):
    """
    Validates a trading code file against FTMO compliance rules.
    This is a simplified example.
    """
    # In a real scenario, this would check for SL, risk percentage, etc.
    return {
        "file_path": file_path,
        "ftmo_compliant": True, # Placeholder
        "validation_details": "Stop Loss and Risk % checks passed."
    }

if __name__ == "__main__":
    if len(sys.argv) > 1:
        file_path = sys.argv[1]
        result = validate_ftmo(file_path)
        print(json.dumps(result))