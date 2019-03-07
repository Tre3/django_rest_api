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

# install Django2.1.7 and uwsgi, and make Django project
RUN pip3 install Django==2.1.7 && \
    pip3 install uwsgi==2.0.18 && \
    mkdir /var/www && \
    cd /var/www && \
    django-admin startproject djangotest

WORKDIR /var/www/djangotest

COPY settings.py /var/www/djangotest/djangotest/settings.py

# install nginx-1.14.2 (http://nginx.org/en/linux_packages.html)
COPY nginx.repo /etc/yum.repos.d/nginx.repo
COPY uwsgi_params /var/www/djangotest/uwsgi_params
RUN yum install -y nginx-1.14.2
COPY nginx.conf /etc/nginx/nginx.conf
COPY djangotest_nginx.conf /etc/nginx/sites-available/djangotest_nginx.conf
RUN cp /etc/nginx/sites-available/djangotest_nginx.conf /var/www/djangotest/djangotest_nginx.conf && \
    mkdir /etc/nginx/sites-enabled && \
    ln -s /var/www/djangotest/djangotest_nginx.conf /etc/nginx/sites-enabled/ && \
    python3 manage.py collectstatic

COPY djangotest_uwsgi.ini /var/www/djangotest/djangotest_uwsgi.ini

# CMD tail -f /dev/null
CMD nginx && \
    uwsgi --ini djangotest_uwsgi.ini

MAINTAINER imai.k@isoroot.jp
