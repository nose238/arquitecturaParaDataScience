docker ps -a -f name=v --format '{{.Names}}' > /tmp/containerNames
while IFS="" read -r p || [ -n "$p" ]
do
    docker start "$p"
    if [ $? -eq 0 ]; then
        printf '\tContainer %s has started correctly\n\n' "$p"
    else
        printf '\tContainer %s has failed to start\n\n' "$p"
    fi
done < /tmp/containerNames