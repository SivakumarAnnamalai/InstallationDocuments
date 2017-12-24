## Script to convert the template to actual contents
source $1
eval "cat <<EOF
$(<$2)
EOF
" 
