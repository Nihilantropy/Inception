FROM alpine:3.19

# Install Python and dependencies
RUN apk update && apk add python3 py3-pip

RUN pip install prometheus-client

# Copy the application files into the container
COPY . .

# Expose the port where the app will be running
EXPOSE 8060

# Command to execute the Python script with correct arguments
CMD ["python3", "src/serve.py", "--root", ".", "--no-browser"]
