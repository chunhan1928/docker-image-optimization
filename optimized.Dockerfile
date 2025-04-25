FROM python:3.10-alpine

WORKDIR /app

# unless requirements.txt changes, docker layers won't change.
# pip install is cached, that's a good thing.
COPY requirements.txt .
RUN pip install -r requirements.txt

# main.py changes often, docker layers will change often.
# doesn't affect pip install cache.
COPY main.py .

# each dockerfile can only have one CMD, so putting it anywhere is ok.
CMD ["python", "main.py"]