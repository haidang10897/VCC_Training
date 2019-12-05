# Security management

# 1. Using Ansible vault
Ansible vault là 1 tính năng có từ phiên bản 1.5. Tính năng này cho phép ta mã hóa mật khẩu như 1 phần của source code. Chúng ta không nên lưu mật khẩu như khóa bí mật, SSL cert, ... dưới dạng bản rõ mà phải mã hóa chúng đi. Ansible vault sẽ giúp ta bảo vệ các dữ liệu bằng cách mã hóa và giải mã chúng.  

Ansible vault hỗ trợ 2 loại:
- Interactive mode sẽ hỏi ta phải cung cấp mật khẩu
- Non-interactive mode thì ta phải chỉ định nơi chứa file mật khẩu để Ansible đọc ở đó.  

Ví dụ, ta sẽ dùng password là `ansible`  , ta sẽ tạo 1 file bí mật tên là `.password `và lưu pass trong đó.  
```
echo 'ansible' > .password
```  

Giờ ta sẽ thử interactive mode trước. Ví dụ ta sẽ tạo mới 1 file tên là `secret.yaml` và ghi vào trong đó là `This is a password protected file`.  
```
ansible-vault create secret.yaml
```  

Khi mở file ra ta sẽ đọc được như sau:  
```
$ANSIBLE_VAULT;1.1;AES256
663464313339336634613833313937636665383731633365363533356465323231353
83630646366
3432353561393533623764323961666639326132323331370a6363636130326166643
33039356565
646437356261626461663138613665323231616461373336343333363930623034613
43638333737
```  

Để xem được file, ta phải dùng lệnh sau, sau khi gõ lệnh này ta sẽ nhập pass để xem:  
```
ansible-vault view secret.yaml
```  
Ta cũng có thể dùng non-interactive mode để xem file bằng cách chỉ định đường dẫn đến file chứa mật khẩu.  

```
ansible-vault --vault-password-file=.password view secret.yaml
```  
Một số lệnh khác:  
```
ansible-vault --vault-password-file=.password edit secret.yaml  
ansible-vault --vault-password-file=.password decrypt secret.yaml  
ansible-vault --vault-password-file=.password encrypt secret.yaml  

```  

***Note: Ta cũng có thể dùng ansible vault và playbook cùng nhau, nhưng mà ta phải decrypt file luôn lúc đó như ví dụ sau:**  
```
ansible-playbook site.yml --vault-password-file .password
```  

# 2. Encrypting user password 

Ansible sẽ lo cho password mà ta nhập vào và sẽ giúp ta baor vệ chúng khi ta chạy playbook hay lệnh. Khi Ansible chạy, nhiều khi ta phải cần user nhập pass. Mà ta lại không muốn pass hiện lên Ansible log hay stdout.  
Ansible dùng `Passlib` là hàm băm mật khẩu của Python để mã hóa mật khẩu nhập vào. Dưới đây là danh sách các hàm băm:  
```
des_crypt: DES Crypt
bsdi_crypt: BSDi Crypt
bigcrypt: BigCrypt
crypt16: Crypt16
md5_crypt: MD5 Crypt
bcrypt: BCrypt
sha1_crypt: SHA-1 Crypt
sun_md5_crypt: Sun MD5 Crypt
sha256_crypt: SHA-256 Crypt
sha512_crypt: SHA-512 Crypt
apr_md5_crypt: Apache's MD5-Crypt variant
phpass: PHPass' Portable Hash
pbkdf2_digest: Generic PBKDF2 Hashes
cta_pbkdf2_sha1: Cryptacular's PBKDF2 hash
dlitz_pbkdf2_sha1: Dwayne Litzenberger's PBKDF2 hash
scram: SCRAM Hash
bsd_nthash: FreeBSD's MCF-compatible nthash encoding
```  

# 3. Using no_log

Ở thời điểm viết sách, Ansible chưa hộx trợ hiding task. Ta có thể hide toàn bộ task dùng `no_log` nhuư sau:  
```
- name: Running a script
shell: script.sh
password: my_password
no_log: True
```  
Với việc dùng `no_log`, Ansible sẽ ngăn chặn toàn bộ task bị ghi vào syslog.
