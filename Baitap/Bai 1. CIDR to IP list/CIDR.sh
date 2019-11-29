#!/bin/bash 

# CIDR co dang a.b.c.d/prefix 
net=$(echo $1 | cut -d '/' -f 1); # lay field net
prefix=$(echo $1 | cut -d '/' -f 2); # lay field prefix
                                                                                                                                                                                                                                        
# Buoc 1: tinh subnet mask
    
    # host=$(( 32 - prefix )); # tinh so bit

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

        # bitmask="${bitmask}${cach}${num}"
bitmask="$bitmask$cach$num"
    done
    echo $bitmask



# Buoc 2: Tinh wild card tu bit subnetmask

wildcard_mask=
    for octet in $bitmask; do
        wildcard_mask="$wildcard_mask $(( 255 - 2#$octet ))" # doi nhi phan sang thap phan roi tinh octet o he 10
    done
    echo $wildcard_mask;

	# echo $range
	# echo $mask_octet
	# echo $wildcard_mask




str=
        for (( i = 1; i <= 4; i++ )); do
            range=$(echo $net | cut -d '.' -f $i)
            mask_octet=$(echo $wildcard_mask | cut -d ' ' -f $i)
            if [ $mask_octet -gt 0 ]; then # neu ma octet cua wildcard >0 thi cong vao, vi du 192.168.1.0/26 -> 192.168.0.{0..63}
                range="{$range..$mask_octet}"; # bien range co dang {..} dung de print lan luot
            fi
            str="$str $range"
        done
        ips=$(echo $str | sed "s, ,\\.,g"); ## thay the chuoi
        eval echo $ips | tr ' ' '\n' # in co new line
  # echo $ips

