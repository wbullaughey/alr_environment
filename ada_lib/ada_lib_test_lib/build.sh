source ~/.zshrc
export WHICH=$1

# WHICH values
#   all     - build everything (help_tests, driver unit tests, applications)
#   execute    - build application or library for subdirectory level
#   help_test  - builds help_test at level

echo build WHICH $WHICH

../../global_build.sh $WHICH library
