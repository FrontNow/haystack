cd ~/ai
git pull
cd ~/haystack
docker-compose stop
git pull
docker-compose up --build
