



# Tao file de luu task
touch ./task.txt

# Option 1: add task
task="$2" # tao bien task va gan gia tri la argument thu 2
cach=" " # dau cach

if [ $1 == 'add' ]; then # cau lenh phai la add ... neu khong se bao loi
    if [ $2 == '']; then
	echo "Loi, phai them task"
    else
      for ((i=0 ; i <= $# ; i++)) # Lenh for nay se doc tung argument (vi task co dau cach)
      do
          task="${task}${cach}$3" # cong don cac argument thanh 1 chuoi
          shift # bat buoc phai co shift de doc tung argument
      done
      echo $task >> task.txt # ghi vao file
	echo "Da add xong task"
    fi
fi


# Option 2: List task

if [ $1 == 'list' ]; then
    	echo "##To do list##"
	cat -n ./task.txt # doc file task.txt va co so line

fi

# Option 3: Remove task

if [ $1 = 'remove' ]; then
	if [[ $2 =~ ^[0-9]+$ ]]; then # phai chon so task de xoa, neu khong se bao loi
		sed -i "$2d" task.txt
	else
		echo 'Loi, phai chon so task'
    	fi

fi
