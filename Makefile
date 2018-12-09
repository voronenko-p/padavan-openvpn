ca_certificate_and_private_key:
	mkdir -p ca_certificate_and_private_key && cd ca_certificate_and_private_key && openssl req -nodes -x509 -days 3650 -newkey rsa:2048 -outform PEM -out ca.crt -keyout ca.key -sha1 -subj '/CN=Home Router CA'
	chmod 600 ca_certificate_and_private_key/ca.key
	openssl x509 -text -noout -in ca_certificate_and_private_key/ca.crt
	mkdir -p outcomes/ca/
	cp ca_certificate_and_private_key/* outcomes/ca/

server_certificate:
	mkdir -p server_certificate
	# create certificate signing request
	cd server_certificate
	openssl req -nodes -days 3650 -newkey rsa:2048 -outform PEM -out server_certificate/server.csr -keyout server_certificate/server.key -sha1 -subj '/CN=home.router.local'
	echo $(PWD)
	openssl x509 -req -in server_certificate/server.csr -CA ca_certificate_and_private_key/ca.crt -CAkey ca_certificate_and_private_key/ca.key -CAcreateserial -clrext -out server_certificate/server.crt -sha1
	rm -f server_certificate/server.csr
	chmod 600 server_certificate/server.key
	openvpn --genkey --secret server_certificate/ta.key
	chmod 600 server_certificate/ta.key
	openssl dhparam -out server_certificate/dh1024.pem 1024
	mkdir -p outcomes/server/
	cp server_certificate/* outcomes/server/


client1:
	mkdir -p client_certificate/client1
	openssl req -nodes -days 3650 -newkey rsa:2048 -outform PEM -out client_certificate/client1/client.csr -keyout client_certificate/client1/client.key -sha1 -subj '/CN=client1.router.local'
	chmod 600 client_certificate/client1/client.key
	openssl req -text -noout -in client_certificate/client1/client.csr
	openssl x509 -req -in client_certificate/client1/client.csr -CA ca_certificate_and_private_key/ca.crt -CAkey ca_certificate_and_private_key/ca.key -CAcreateserial -clrext -out client_certificate/client1/client.crt -sha1


client2:
	mkdir -p client_certificate/client2
	openssl req -nodes -days 3650 -newkey rsa:2048 -outform PEM -out client_certificate/client2/client.csr -keyout client_certificate/client2/client.key -sha1 -subj '/CN=client2.router.local'
	chmod 600 client_certificate/client2/client.key
	openssl req -text -noout -in client_certificate/client2/client.csr
	openssl x509 -req -in client_certificate/client2/client.csr -CA ca_certificate_and_private_key/ca.crt -CAkey ca_certificate_and_private_key/ca.key -CAcreateserial -clrext -out client_certificate/client2/client.crt -sha1


deploy:
	scp -r outcomes/server/* admin@192.168.1.1:/etc/storage/openvpn/server/
	scp -r outcomes/ca/*     admin@192.168.1.1:/etc/storage/openvpn/server/

commit_to_rom:
	ssh admin@192.168.1.1 "mtd_storage.sh save"
