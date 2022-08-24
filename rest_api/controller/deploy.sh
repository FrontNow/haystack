cd ~/ai
git pull
cd ~/haystack
docker-compose stop
git pull
docker-compose build --no-cache
docker-compose up
