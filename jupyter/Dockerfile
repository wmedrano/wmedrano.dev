FROM python:3
WORKDIR /usr/src/app

# Install dependencies.
RUN pip install jupyterlab numpy pandas matplotlib

# Create config directory for jupyter.
RUN mkdir -p root/.jupyter

# Export config directory and notebook directory.
VOLUME ["/root/.jupyter", "/usr/src/app"]

EXPOSE 21894/tcp
CMD ["jupyter", "lab" , "--port=21894", "--allow-root", "--no-browser", "--ip=*"]