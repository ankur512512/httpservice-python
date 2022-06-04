FROM python:3.9.13-alpine

WORKDIR /python-docker

COPY resources/* ./
RUN pip3 install -r requirements.txt

ENV FLASK_APP=httpService.py

CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0"]