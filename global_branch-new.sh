# 2. Create & switch to the new branch in the superproject
git switch -c feature/big-refactor
# or older style: git checkout -b feature/big-refactor

# 3. Create the same branch name in every submodule + switch to it
git submodule foreach 'git switch -c feature/big-refactor || git switch feature/big-refactor'

#    Explanation:
#    - -c = create & switch   (fails silently if already exists → falls back)
#    - without -c = just switch (if it already exists)

# 4. (Optional but very common) Make the submodules track the branch with the **same name** as parent
#    This is super useful for future `git submodule update --remote` calls
git submodule foreach 'git config -f "$toplevel/.gitmodules" submodule.$name.branch $(git rev-parse --abbrev-ref HEAD)'
# or even better — set it to magical "." value (means "same name as superproject branch")
git submodule foreach 'git config -f "$toplevel/.gitmodules" submodule.$name.branch .'
git add .gitmodules
git commit -m "Submodules now track branch '.' (same name as superproject)"
