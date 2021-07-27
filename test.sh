IFS='.'
read -a strarr <<<"$1"

if [ ${#distro[@]} -eq 3 ]
then
    SITE_NAME=${strarr[1]}
else
    SITE_NAME=${strarr[0]}
fi