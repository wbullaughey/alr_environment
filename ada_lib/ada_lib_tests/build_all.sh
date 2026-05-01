#source ~/.zshrc
export OUTPUT=build_all.txt
./build.sh 2>&1 | tee $OUTPUT


