#!/bin/bash

# Script to create a new branch in a Git project with submodules
# Usage: ./create_branch.sh <branch-name> [base-branch]

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not a git repository!"
    exit 1
fi

# Check if branch name is provided
if [ -z "$1" ]; then
    print_error "Branch name is required!"
    echo "Usage: $0 <branch-name> [base-branch]"
    exit 1
fi

BRANCH_NAME="$1"
BASE_BRANCH="${2:-main}"  # Default to 'main' if not specified

# Check if branch already exists
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    print_error "Branch '$BRANCH_NAME' already exists!"
    exit 1
fi

print_info "Creating branch '$BRANCH_NAME' from '$BASE_BRANCH'..."

# Checkout base branch
print_info "Checking out base branch '$BASE_BRANCH'..."
git checkout "$BASE_BRANCH"

# Update base branch
print_info "Pulling latest changes..."
git pull origin "$BASE_BRANCH"

# Create and checkout new branch
print_info "Creating new branch '$BRANCH_NAME'..."
git checkout -b "$BRANCH_NAME"

# Check if there are submodules
if [ -f .gitmodules ]; then
    print_info "Submodules detected. Initializing and updating..."

    # Initialize submodules if not already done
    git submodule init

    # Update submodules to match the parent repository
    git submodule update --recursive

    # Optionally, create matching branches in submodules
    read -p "Do you want to create matching branches in submodules? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git submodule foreach --recursive "
            git checkout '$BASE_BRANCH' 2>/dev/null || git checkout master 2>/dev/null || echo 'Could not checkout base branch';
            git pull 2>/dev/null || echo 'Could not pull';
            git checkout -b '$BRANCH_NAME' 2>/dev/null || echo 'Branch may already exist'
        "
        print_info "Branches created in submodules"
    fi
else
    print_warning "No submodules found in this repository"
fi

print_info "Branch '$BRANCH_NAME' created successfully!"
print_info "Current branch: $(git branch --show-current)"

# Show status
echo ""
git status
