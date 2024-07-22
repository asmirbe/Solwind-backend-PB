# Use the official Go image to build the PocketBase binary
FROM golang:1.21-alpine AS builder

# Set the working directory
WORKDIR /app

# Copy go mod and sum files
COPY go.mod go.sum ./

# Download all dependencies
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the PocketBase application
RUN CGO_ENABLED=0 GOOS=linux go build -o pocketbase .

# Start a new stage from scratch
FROM alpine:latest

# Install necessary packages
RUN apk add --no-cache ca-certificates

# Set the working directory
WORKDIR /pb

# Copy the PocketBase binary from builder
COPY --from=builder /app/pocketbase ./pocketbase

# Set environment variables
ENV POCKETBASE_API_KEY=your_api_key
ENV PORT=8080
# Expose port 8080
EXPOSE 8080

# Command to run PocketBase
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8080"]
