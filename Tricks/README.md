# Windows Tricks
- [Delete tên file quá dài](./How%20to%20delete%20The%20file%20name%20is%20too%20long%20in%20windows.pdf)  


# Linux Tricks
- [Delete mọi dòng comment](./Vim,%20removing%20blank%20and%20commented%20lines%20in%20one%20regex.pdf)  
- Lấy link ảnh trong album imgur
	```sh
	curl http://imgur.com/a/j1ddA|
	grep -o '<div id="[^"]*" class="post-image-container'|
	cut -d\" -f2|
	sed 's,.*,http://i.imgur.com/&.jpg,'
	```  