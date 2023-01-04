FROM golang:1.19.3-alpine

WORKDIR /app

COPY go.mod ./
COPY *.go ./

RUN go build -o /main

EXPOSE 8080

CMD [ "/main" ]

