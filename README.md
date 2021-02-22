# Dns-Cat
Multi-platform toolkit for an interactive DNS shell commands exfiltration, by using DNS-Cat, you will be able to execute system commands in shell mode and exfiltrate the results over a covert channel.
both Server and Client support XOR encryption which made it hard to be detected by advanced inspection tools, the way of encryption starting with XORing the buffer of strings and then encode it with base64.

While on the server side it will decode the base64 content then decrypt it with same Symmetric key
 
[<img align="right" src="https://github.com/lawrenceamer/0xsp/blob/master/imgs/DNS-Cat.png?raw=true" height="512" width="500">]()

### Server 
ported as a python script, which acts as DNS server with required functionalities to provide interactive shell command interface.

```
Python3 server.py -d DOMAIN_NAME -a DOMAIN_IP -i INTERFACEIP 
```

### Client 
Coded using Pascal and ported with the following formats :

* Windows 32/64 executable (exe) 
* MacOS Darwin 
* Linux 32/64 executable (ELF)
* PowerShell Script (ps1)
* Dynamic Link Library (DLL)

### Highlights 

* The agent supports Multi-platforms.
* built-in feature with 0xsp-mongoose RED. 
* Multi extensions.  
* Support XOR encryption.   
* Speed and stability. 
* Stealth and undetectable.

### Releases 

|   System      |   Supported   |
| ------------- |:-------------:|
| Windows       |     YES       | 
| Linux         |     YES       |
| MacOS         |     YES       | 
| BSD           |     YES       |
| Android       |     Still     |
