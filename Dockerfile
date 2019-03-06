FROM centos:7

# install build tools and libraries
RUN yum -y groupinstall "development tools" && \
    yum install -y bzip2-devel gdbm-devel libffi-devel \
    libuuid-devel ncurses-devel openssl-devel readline-devel \
    sqlite-devel tk-devel wget xz-devel zlib-devel

# install python3.7.2
RUN cd /tmp && \
    curl https://www.python.org/ftp/python/3.7.2/Python-3.7.2.tgz -o Python-3.7.2.tgz && \
    tar xzf Python-3.7.2.tgz && \
    cd Python-3.7.2 && \
    ./configure --enable-shared && \
    make && \
    make install && \
    sh -c "echo '/usr/local/lib' > /etc/ld.so.conf.d/custom_python3.conf" && \
    ldconfig

# install Django2.1.7 and uwsgi, and run Django
RUN pip3 install Django==2.1.7 && \
    pip3 install uwsgi==2.0.18 && \
    cd && \
    django-admin startproject djangotest

COPY settings.py /root/djangotest/djangotest
COPY nginx.repo /etc/yum.repos.d/nginx.repo

# install nginx-1.14.2
RUN yum install -y nginx-1.14.2

WORKDIR /root/djangotest

CMD python3 manage.py runserver 0.0.0.0:8000

MAINTAINER imai.k@isoroot.jp
