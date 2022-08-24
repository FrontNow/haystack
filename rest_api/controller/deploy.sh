cd ~/ai
git pull
cd ~/haystack
docker-compose stop
git pull
docker-compose -f docker-compose-gpu.yml up
