FROM python:3.7-alpine


RUN pip install flask requests

RUN mkdir /app
WORKDIR /app
COPY main.py main.py

CMD python main.py
