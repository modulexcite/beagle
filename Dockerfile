FROM python:3.6.8


RUN apt-get update && apt-get install -y \
    g++ \
    gcc \
    libxslt-dev \
    libssl-dev \
    libffi-dev \
    bash \
    ncurses-dev \
    curl \
    libncurses5-dev \
    libncursesw5-dev \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm typescript

RUN mkdir -p /opt/beagle/beagle/web/static

COPY Pipfile Pipfile.lock /opt/beagle/

WORKDIR /opt/beagle

RUN pip install pipenv && pipenv install --system --skip-lock

COPY beagle/web/static/package.json beagle/web/static/package-lock.json /opt/beagle/beagle/web/static/

WORKDIR /opt/beagle/beagle/web/static

RUN npm install  && npm audit fix

COPY . /opt/beagle

WORKDIR /opt/beagle/beagle/web/static

RUN npm run build

WORKDIR /opt/beagle

RUN mkdir -p /data/beagle && python setup.py install

EXPOSE 8000

CMD gunicorn --bind 0.0.0.0:8000 -w 12 --timeout 500 beagle.web.wsgi:app

