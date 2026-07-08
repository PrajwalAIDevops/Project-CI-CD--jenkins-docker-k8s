FROM python:3.12-slim
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
RUN groupadd -r devops && \
    useradd -r -g devops -m devops && \
    chown -R devops:devops /app
USER devops
EXPOSE 5000
CMD ["python","app.py"]
