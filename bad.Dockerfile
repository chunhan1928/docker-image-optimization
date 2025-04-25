FROM python:3.10-alpine

WORKDIR /app

# when main.py changes, docker layers will change
# when lower level layer changes, upper layer will be rebuilt.
# forcing pip install to run again. This is bad.
COPY . .
RUN pip install -r requirements.txt

CMD ["python", "main.py"]