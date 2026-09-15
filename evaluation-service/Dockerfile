FROM golang:1.26-alpine AS build

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /bin/evaluation-service .

FROM alpine:3.20

RUN addgroup -g 10001 -S app && adduser -u 10001 -S app -G app
WORKDIR /app

COPY --from=build /bin/evaluation-service /app/evaluation-service

USER 10001:10001
EXPOSE 8004

ENTRYPOINT ["/app/evaluation-service"]
