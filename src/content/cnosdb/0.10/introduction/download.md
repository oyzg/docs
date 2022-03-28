# 下载


## Ubuntu & Debian
> MD5: dcf746639719bd949d0a5dfd801a3706
```shell
wget https://github.com/cnosdb/cnosdb/releases/download/v0.10.2/cnosdb_0.10.2_amd64.deb
sudo dpkg -i cnosdb_0.10.2_amd64.deb
```

## Docker Image

```shell
docker pull cnosdb:0.10.2
```

## RedHat & CentOS
> MD5: 625d771599f17287fecfeec2ed8a5970
```shell
wget https://github.com/cnosdb/cnosdb/releases/download/v0.10.2/cnosdb-0.10.2.x86_64.rpm
sudo yum localinstall cnosdb-0.10.2.x86_64.rpm
```

## macOS
> MD5: ae94172c9b250d0c875a07b3e2a62128
```shell
wget https://github.com/cnosdb/cnosdb/releases/download/v0.10.2/cnosdb-0.10.2_darwin_amd64.tar.gz
tar zxvf cnosdb-0.10.2_darwin_amd64.tar.gz
```

## Windows Binaries(64-bit) - using PowerShell
> MD5: e087e1962c9f9af40140bf26d4cffad9
```shell
wget https://github.com/cnosdb/cnosdb/releases/download/v0.10.2/cnosdb-0.10.2_windows_amd64.zip -UseBasicParsing -OutFile cnosdb-0.10.2_windows_amd64.zip
Expand-Archive .\cnosdb-0.10.2_windows_amd64.zip -DestinationPath 'C:\Program Files\CnosDB\cnosdb\'
```

## Linux Binaries(64-bit)
> MD5: e97e131814f2ee0718b10871fce73601
```shell
wget https://github.com/cnosdb/cnosdb/releases/download/v0.10.2/cnosdb-0.10.2_linux_amd64.tar.gz
tar xvfz cnosdb-0.10.2_linux_amd64.tar.gz
```
## Linux Binaries(64-bit, static)
> MD5: 66f94d9bd70918dfa7051bd866a374b4
```shell
wget https://github.com/cnosdb/cnosdb/releases/download/v0.10.2/cnosdb-0.10.2-static_linux_amd64.tar.gz
tar xvfz cnosdb-0.10.2-static_linux_amd64.tar.gz
```

## Linux Binaries(32-bit)
MD5: 0202acf5c3856f113f73670908787c99
```shell
wget https://github.com/cnosdb/cnosdb/releases/download/v0.10.2/cnosdb-0.10.2_linux_i386.tar.gz
tar xvfz cnosdb-0.10.2_linux_i386.tar.gz
```

## Linux Binaries(ARMv7)
MD5: f6b1d55ff9dba5edf9ae898034e848ec
```shell
wget https://github.com/cnosdb/cnosdb/releases/download/v0.10.2/cnosdb-0.10.2_linux_armhf.tar.gz
tar xvfz cnosdb-0.10.2_linux_armhf.tar.gz
```

## Linux Binaries(ARMv8)
MD5: e84241a0dd6618cf1d296c31e9c1298e
```shell
wget https://github.com/cnosdb/cnosdb/releases/download/v0.10.2/cnosdb-0.10.2_linux_arm64.tar.gz
tar xvfz cnosdb-0.10.2_linux_arm64.tar.gz
```

## 验证下载二进制文件的真实性（可选）

为了验证安全性，请按照以下步骤验证您下载的CnosDB的`gpg`签名（大多数系统默认包含`gpg`命令，如果`gpg`不可用，请参阅[Gun主页](https://gnupg.org/download)获取安装说明。
1. 下载并导入CnosDB公钥
   ```
   curl -s https://www.cnosdb.com/cnosdb.key | gpg --import
   ```
2. 通过在URL上添加`.asc`来下载指定版本的签名文件
   ```shell
    wget https://github.com/cnosdb/cnosdb/releases/download/v0.10.2/cnosdb-0.10.2_linux_amd64.tar.gz
   ```
3. 验证签名 `gpg --verify`
    ```shell
    gpg --verify cnosdb-0.10.2_linux_amd64.tar.gz.asc cnosdb-0.10.2_linux_amd64.tar.gz
    ```
   此命令应该输出：
    ```shell
    gpg: Good signature from "CnosDB <contact@cnosdb.com>" [unknown]
    ```