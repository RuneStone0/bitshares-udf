FROM python:3.6-slim

# Create user and change cwd
ARG USERNAME=dockerman
RUN useradd -ms /bin/bash $USERNAME
WORKDIR /home/$USERNAME

# Setup app + gunicorn
COPY requirements.txt ./
RUN python -m venv venv
RUN venv/bin/pip install --upgrade pip
RUN venv/bin/pip install -r requirements.txt
RUN venv/bin/pip install gunicorn
COPY app app
COPY run.py ./
RUN chown -R $USERNAME:$USERNAME ./

# Setup nginx
RUN apt-get update
RUN apt-get install -y nginx nginx-extras --no-install-recommends
RUN mkdir -p /run/nginx && touch /var/run/nginx.pid
RUN chown -R $USERNAME:$USERNAME /var/log/nginx /var/lib/nginx /var/run/nginx.pid
COPY Docker/nginx.conf /etc/nginx/nginx.conf

# Setup supervisor
RUN apt-get install -y supervisor
COPY Docker/supervisord.conf /etc/supervisord.conf

# Clean up and switch user to 
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
USER $USERNAME

# gunicorn:5000
# nginx:8000
EXPOSE 8000
ENTRYPOINT ["supervisord", "-c", "/etc/supervisord.conf"]
