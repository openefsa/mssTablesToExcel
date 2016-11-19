FROM r-base

RUN apt-get update && apt-get -t unstable install -y libxml2-dev libcurl4-openssl-dev libssl-dev
RUN install.r shiny xml2 tidyverse openxlsx
COPY *.R /home/docker/

WORKDIR /home/docker
CMD ["R", "-e", "shiny::runApp(port=8888,host='0.0.0.0')"]



