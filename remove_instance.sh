echo -e "Running instance removal script . . . . \n"
ls -d docker-compose-*
echo -e "\nType instance name (without docker-compose- & .yml) e.g. \"test\" "
read name
echo -e "\nRemove \"${name}\" [y/n]?"
read ans
if [ $ans == "Y" -o $ans == "y" ]; then
        {
	echo -e "\n Dismissing $name . . ."
        docker-compose -f docker-compose-$name.yml down
        echo -e "Removing associated docker file . . . \n"
        rm  docker-compose-$name.yml
        }
else
        exit 1
fi
