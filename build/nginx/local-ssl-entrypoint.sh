#!/bin/bash
set -e

path="/etc/nginx"

# get all domain in nginx
cat $path/conf.d/*.conf | sed -r -e 's/[ \t]*$//' -e 's/^[ \t]*//' -e 's/^#.*$//' -e 's/[ \t]*#.*$//' -e '/^$/d' | \
	sed -e ':a;N;$!ba;s/\([^;\{\}]\)\n/\1 /g' | \
	grep -P 'server_name[ \t]' | grep -v '\$' | \
	sed -r -e 's/(\S)[ \t]+(\S)/\1\n\2/g' -e 's/[\t ]//g' -e 's/;//' -e 's/server_name//' | \
	sort | uniq | xargs -L1 > $path/domains.txt

if [ -f $path/domains.txt ]; then
	if [ ! -d "$path/ssl" ]; then
	    mkdir $path/ssl
	fi

	if [ ! -d "$path/ssl/domains" ]; then
	    mkdir $path/ssl/domains
	fi

	if [ ! -f $path/ssl/dh.pem ]; then
		openssl dhparam -out $path/ssl/dh.pem 2048
	fi

	if [ ! -f $path/ssl/rootCA.pem ]; then
		openssl rand -base64 48 > $path/ssl/passphrase.txt

	    openssl genrsa -des3 -passout file:$path/ssl/passphrase.txt \
	    	-out $path/ssl/rootCA.key 2048

	    openssl req -x509 -new -nodes -key $path/ssl/rootCA.key -sha256 -days 36500 \
	    	-passin file:$path/ssl/passphrase.txt \
	    	-out $path/ssl/rootCA.pem \
	    	-subj "/C=VN/ST=Hanoi/L=Hanoi/O=BssGroup/OU=Information Technology/CN=BssGroup"
	fi

	for i in $(cat $path/domains.txt); do
	    if [ ! -d "$path/ssl/domains/$i" ]; then
		    mkdir $path/ssl/domains/$i
		    openssl genrsa -out $path/ssl/domains/$i/rsa.key 2048

			openssl req -new -key $path/ssl/domains/$i/rsa.key \
				-out $path/ssl/domains/$i/rsa.csr \
				-subj "/C=VN/ST=Hanoi/L=Hanoi/O=BssGroup/OU=Information Technology/CN=$i"
		fi
	done

	ext_file="san.ext"
	touch $path/ssl/$ext_file
	echo > $path/ssl/$ext_file

	echo "authorityKeyIdentifier=keyid,issuer" >> $path/ssl/$ext_file
	echo "basicConstraints=CA:FALSE" >> $path/ssl/$ext_file
	echo "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment" >> $path/ssl/$ext_file
	echo "subjectAltName = @alt_names" >> $path/ssl/$ext_file
	echo "" >> $path/ssl/$ext_file
	echo "[alt_names]" >> $path/ssl/$ext_file

	line=0
	for i in $(cat $path/domains.txt); do
		((line+=1))
		echo "DNS.$line = $i" >> $path/ssl/$ext_file
	done

	for i in $(cat $path/domains.txt); do
		if [ ! -f $path/ssl/domains/$i/rsa.crt ]; then
			openssl x509 -req -in $path/ssl/domains/$i/rsa.csr -CA $path/ssl/rootCA.pem \
			-CAkey $path/ssl/rootCA.key -CAcreateserial \
			-out $path/ssl/domains/$i/rsa.crt \
			-days 36500 -sha256 \
			-passin file:$path/ssl/passphrase.txt \
			-extfile $path/ssl/san.ext
		fi
	done
fi

exit 0