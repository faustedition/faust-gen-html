#!/bin/sh

prepare_rc() {
  echo "exist.rc not found: creating a skeleton, fill in the details"
  cat > exist.rc <<EOF
# Path to eXist install root
exist=

# Password for the 'admin' user
password=
EOF
exit 1
}

if [ -r exist.rc ]
then
  . ./exist.rc
else
  prepare_rc
  exit 1
fi

if [ \! -d target/search ]
then
  echo "### Data marked-up for search not found, generating ..."
  if [ \! -r target/faust-transcripts.xml ]
  then
    echo "### Collecting metadata ..."
    calabash -o target/faust-transcripts.xml collect-metadata.xpl
  fi
  calabash -i target/faust-transcripts.xml generate-search.xpl
fi

echo "### Uploading stuff to the local exist instance ..."
${exist}/bin/client.sh -c /db/apps -u admin -P "${password}" -s << EOF
mkcol faust
cd faust
mkcol xslt
mkcol data
put search.xq
chmod search.xq other=+execute
cd xslt
put xslt

cd
cd system
cd config
cd db
mkcol apps
cd apps
mkcol faust
cd faust
mkcol data
cd data
put collection.xconf

cd
cd apps
cd faust
cd data
put target/search
quit
EOF
