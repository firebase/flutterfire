files=`find . -type f -name "*.dart"`

for file in $files
do
#   echo $file
    sed -i '' '1s/^/\/\/ ignore_for_file: require_trailing_commas\'$'\n/' $file
done