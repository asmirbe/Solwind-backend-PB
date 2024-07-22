FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o pocketbase .

FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /app/pocketbase .
COPY pb_migrations ./pb_migrations

EXPOSE 8080

CMD ["./pocketbase", "serve", "--http=0.0.0.0:8080"]