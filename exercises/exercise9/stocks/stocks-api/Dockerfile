FROM public.ecr.aws/amazoncorretto/amazoncorretto:17

RUN mkdir -p /cloudacademy/app
WORKDIR /cloudacademy/app
RUN ls -la

COPY target/stocks-*.jar ./stocks-api.jar

EXPOSE 8080

CMD ["java", "-jar", "stocks-api.jar"]