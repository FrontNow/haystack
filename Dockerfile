FROM --platform=linux/amd64 python:3.7.4-stretch
# I added platform as suggested here: https://stackoverflow.com/questions/65612411/forcing-docker-to-use-linux-amd64-platform-by-default-on-macos/69636473#69636473
# I had the following error: scram authentication requires libpq version 10 or above

WORKDIR /home/user

RUN apt-get update && apt-get install -y \
    curl  \
    git  \
    pkg-config  \
    cmake \
    libpoppler-cpp-dev  \
    tesseract-ocr  \
    libtesseract-dev  \
    poppler-utils && \
    rm -rf /var/lib/apt/lists/*

# install psycopg2 dependencies
RUN apt-get update && apt-get install libpq-dev -y

# Install PDF converter
RUN wget --no-check-certificate https://dl.xpdfreader.com/xpdf-tools-linux-4.04.tar.gz && \
    tar -xvf xpdf-tools-linux-4.04.tar.gz && cp xpdf-tools-linux-4.04/bin64/pdftotext /usr/local/bin

# Copy Haystack code
COPY haystack /home/user/haystack/
# Copy package files & models
COPY pyproject.toml VERSION.txt LICENSE README.md models* /home/user/
# Copy REST API code
COPY rest_api /home/user/rest_api/

# Install package
RUN pip install --upgrade pip
RUN pip install --no-cache-dir .[docstores,crawler,preprocessing,ocr,ray,rest-api]
RUN pip install --no-cache-dir rest_api/
RUN ls /home/user
RUN pip freeze
RUN python3 -c "from haystack.utils.docker import cache_models;cache_models()"

# create folder for /file-upload API endpoint with write permissions, this might be adjusted depending on FILE_UPLOAD_PATH
RUN mkdir -p /home/user/rest_api/file-upload
RUN chmod 777 /home/user/rest_api/file-upload

# optional : copy sqlite db if needed for testing
#COPY qa.db /home/user/

# optional: copy data directory containing docs for ingestion
#COPY data /home/user/data

EXPOSE 8000
ENV HAYSTACK_DOCKER_CONTAINER="HAYSTACK_CPU_CONTAINER"

# cmd for running the API
CMD ["gunicorn", "rest_api.application:app", "-b", "0.0.0.0", "-k", "uvicorn.workers.UvicornWorker", "--workers", "1", "--timeout", "600"]
