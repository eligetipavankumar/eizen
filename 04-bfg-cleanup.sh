#!/bin/bash

# Task 1.4: Remove large file from git history using BFG Repo-Cleaner

set -e

LOG_FILE="bfg_cleanup.log"

echo "BFG Repo-Cleaner Cleanup Process" | tee "$LOG_FILE"
echo "=================================" | tee -a "$LOG_FILE"

# Check if BFG is installed
if ! command -v bfg &> /dev/null; then
    echo "BFG Repo-Cleaner not found." | tee -a "$LOG_FILE"

    # If Java isn't available, exit early
    if ! command -v java &> /dev/null; then
        echo "Java is required to run BFG. Please install Java and re-run." | tee -a "$LOG_FILE"
        exit 1
    fi

    # Offer to download BFG jar and create a local wrapper in ./bin
    read -p "Would you like to download BFG automatically to ./bin and create wrapper? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        BFG_VERSION="1.14.0"
        BFG_JAR_URL="https://repo1.maven.org/maven2/com/madgag/bfg/${BFG_VERSION}/bfg-${BFG_VERSION}.jar"
        BIN_DIR="./bin"
        mkdir -p "$BIN_DIR"

        echo "Downloading BFG ${BFG_VERSION}..." | tee -a "$LOG_FILE"
        if command -v curl &> /dev/null; then
            curl -L -o "$BIN_DIR/bfg.jar" "$BFG_JAR_URL" 2>&1 | tee -a "$LOG_FILE"
        elif command -v wget &> /dev/null; then
            wget -O "$BIN_DIR/bfg.jar" "$BFG_JAR_URL" 2>&1 | tee -a "$LOG_FILE"
        else
            # Try PowerShell on Windows
            if command -v pwsh &> /dev/null || command -v powershell &> /dev/null; then
                echo "Using PowerShell to download BFG..." | tee -a "$LOG_FILE"
                if command -v pwsh &> /dev/null; then
                    pwsh -Command "Invoke-WebRequest -Uri '$BFG_JAR_URL' -OutFile '$BIN_DIR/bfg.jar'"
                else
                    powershell -Command "Invoke-WebRequest -Uri '$BFG_JAR_URL' -OutFile '$BIN_DIR\bfg.jar'"
                fi
            else
                echo "No download tool (curl/wget/powershell) found. Please download BFG manually:" | tee -a "$LOG_FILE"
                echo "  $BFG_JAR_URL" | tee -a "$LOG_FILE"
                exit 1
            fi
        fi

        # Create wrapper script
        WRAPPER="$BIN_DIR/bfg"
        echo "Creating wrapper at $WRAPPER" | tee -a "$LOG_FILE"
        cat > "$WRAPPER" <<'BFGWRAPPER'
#!/bin/sh
exec java -jar "$(dirname "$0")/bfg.jar" "$@"
BFGWRAPPER
        chmod +x "$WRAPPER"

        # Prepend our bin dir to PATH for this script execution
        export PATH="$(cd "$BIN_DIR" && pwd):$PATH"

        if ! command -v bfg &> /dev/null; then
            echo "Wrapper created but 'bfg' not found in PATH. You may need to open a new shell or add $BIN_DIR to your PATH." | tee -a "$LOG_FILE"
            echo "Attempting to use the local wrapper directly..." | tee -a "$LOG_FILE"
        else
            echo "BFG installed and wrapper available." | tee -a "$LOG_FILE"
        fi
    else
        echo "Please install BFG manually from: https://rtyley.github.io/bfg-repo-cleaner/" | tee -a "$LOG_FILE"
        exit 1
    fi
fi

# Step 1: Create a mirror clone
echo "Creating a mirror clone of the repository..." | tee -a "$LOG_FILE"
git clone --mirror . ../repo.git 2>&1 | tee -a "$LOG_FILE"

# Step 2: Run BFG to remove large files
echo "Running BFG to remove files larger than 1GB..." | tee -a "$LOG_FILE"
bfg --strip-blobs-bigger-than 1G ../repo.git 2>&1 | tee -a "$LOG_FILE"

# Step 3: Reflog expire and garbage collection
echo "Cleaning up and compressing repository..." | tee -a "$LOG_FILE"
cd ../repo.git
git reflog expire --expire=now --all
git gc --prune=now
cd -

# Step 4: Push cleaned repository
echo "Instructions for replacing remote repository:" | tee -a "$LOG_FILE"
echo "1. Push the cleaned repository:" | tee -a "$LOG_FILE"
echo "   git push --force --mirror ../repo.git" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "2. Or replace the current origin:" | tee -a "$LOG_FILE"
echo "   git clone ../repo.git ." | tee -a "$LOG_FILE"

echo "BFG cleanup completed!" | tee -a "$LOG_FILE"
