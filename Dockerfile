FROM openanalytics/r-base

MAINTAINER Carsten Behring "carsten.behring@efsa.europa.eu"

RUN apt-get update && apt-get install -y libxml2-dev libcurl4-openssl-dev libssl-dev
RUN install.r shiny xml2 tidyverse openxlsx devtools

RUN mkdir /root/mssTablesToExcel
COPY mssTablesToExcel_0.0.2.tar.gz /root/
RUN R CMD INSTALL /root/mssTablesToExcel_0.0.2.tar.gz

EXPOSE 3838

CMD ["R", "-e", "mssTablesToExcel::runShiny(port=3838,host='0.0.0.0')"]




