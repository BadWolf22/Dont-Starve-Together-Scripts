cd ..
wget https://github.com/SteamRE/DepotDownloader/releases/download/DepotDownloader_2.7.2/DepotDownloader-linux-x64.zip
unzip ./DepotDownloader-linux-x64.zip -d depotDownloader
chmod u+x ./depotDownloader/DepotDownloader
./depotDownloader/DepotDownloader -app 343050 -filelist ./Testbed/.github/workflows/files.txt
find -name "scripts.zip" -type f -exec mv -- {} . \;
unzip ./scripts.zip
rm -rf ./Testbed/*
mv -v ./scripts/* ./Testbed