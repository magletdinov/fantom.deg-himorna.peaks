FROM rocker/r-ver:4.4.2

# Установка системных зависимостей
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libx11-dev git libcurl4-openssl-dev libssl-dev make zlib1g-dev \
    pandoc libfreetype6-dev libjpeg-dev libpng-dev libtiff-dev libicu-dev \
    libfontconfig1-dev libfribidi-dev libharfbuzz-dev libxml2-dev \
    libgit2-dev \
    tcl tk tk-dev tcl-dev libtcl8.6 libtk8.6 \
    libgl1-mesa-dev libglu1-mesa-dev \
    && rm -rf /var/lib/apt/lists/*

# Настройка компилятора для R: отключение строгой проверки форматов
RUN mkdir -p /root/.R && echo 'CFLAGS=-Wno-error=format-security' > /root/.R/Makevars

# Установка devtools
RUN R -e "install.packages('devtools', repos='https://cloud.r-project.org/')"

# Рабочая директория
WORKDIR /home/rproject

# Команда по умолчанию
CMD [ "R" ]
