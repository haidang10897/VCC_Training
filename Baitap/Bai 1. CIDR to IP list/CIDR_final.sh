#!/bin/bash 

# CIDR co dang a.b.c.d/prefix 
# Buoc 0: Cat field de lay gia tri net va prefix

net=$(echo $1 | cut -d '/' -f 1); # lay field net
prefix=$(echo $1 | cut -d '/' -f 2); # lay field prefix
                                                                                                                                                                                                                                        
# Buoc 1: tinh subnet mask va doi ra bit
    

    bitmask=""
    for (( i=0; i < 32; i++ )); do
        num=0
        if [ $i -lt $prefix ]; then # bit nao < prefix thi in 1 , nguoc lai 0
            num=1
        fi

        cach=
        if [ $(( i % 8 )) == 0 ]; then # het 1 octet thi them dau cach
            cach=" ";
        fi

       
	bitmask="$bitmask$cach$num" # cong don bien bitmask.
    done
    echo "Gia tri nhi phan cua prefix la: "  
	echo $bitmask



# Buoc 2: Tinh wild card tu bit subnetmask

wildcard_mask=
    for octet in $bitmask; do
        wildcard_mask="$wildcard_mask $(( 255 - 2#$octet ))" # doi nhi phan sang thap phan roi tinh octet o he 10
    done
    echo 'Gia tri wild card la: '
    echo $wildcard_mask;

	

# Buoc 3: Cong field net voi wildcard va in ra man hinh
# Vi du: 172.16.0.0/23 co wild card la 0.0.1.255 thi lan luon cong ip vao wild card -> in ip ra theo kieu 172.16.{0..1}.{0..255}


str=
	echo "List IP cua CIDR la: "
        for (( i = 1; i <= 4; i++ )); do
            range=$(echo $net | cut -d '.' -f $i) # cat tung octet cua phan net
            mask_octet=$(echo $wildcard_mask | cut -d ' ' -f $i) # cat tung octet cua phan wildcard
            if [ $mask_octet -gt 0 ]; then # neu ma octet cua wildcard >0 thi cong vao, vi du 192.168.1.0/26 -> 192.168.0.{0..63}
                range="{$range..$mask_octet}"; # bien range co dang {..} dung de print lan luot
            fi
            str="$str $range" # cong don bien str
        done
        ips=$(echo $str | sed "s, ,\\.,g"); ## thay the chuoi
        eval echo $ips | tr ' ' '\n' # in co new line va in tung ip ra man hinh


