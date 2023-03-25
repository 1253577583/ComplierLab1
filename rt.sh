OUT_PATH=./out
mkdir -p $OUT_PATH
for entry in `ls $1`; do
    ./parser $1/$entry > $OUT_PATH/${entry}_out.txt 2>&1
done
