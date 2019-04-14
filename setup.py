#!/usr/bin/env python
"""
setup.py for pgmigrate
"""
# encoding: utf-8
#
#    Copyright (c) 2016-2019 Yandex LLC <https://github.com/yandex>
#    Copyright (c) 2016-2019 Other contributors as noted in the AUTHORS file.
#
#    Permission to use, copy, modify, and distribute this software and its
#    documentation for any purpose, without fee, and without a written
#    agreement is hereby granted, provided that the above copyright notice
#    and this paragraph and the following two paragraphs appear in all copies.
#
#    IN NO EVENT SHALL YANDEX LLC BE LIABLE TO ANY PARTY FOR DIRECT,
#    INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST
#    PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
#    EVEN IF YANDEX LLC HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#    YANDEX SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT
#    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
#    PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS"
#    BASIS, AND YANDEX LLC HAS NO OBLIGATIONS TO PROVIDE MAINTENANCE,
#    SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.

import sys

try:
    from setuptools import setup
except ImportError:
    from distutils import setup

REQUIREMENTS = [
    'sqlparse >= 0.3.0',
    'psycopg2 >= 2.8.2',
    'PyYAML >= 5.1',
]

if sys.version_info < (3, 0):
    REQUIREMENTS.append('future >= 0.17.1')

setup(
    name='yandex-pgmigrate',
    version='1.0.3',
    description='PostgreSQL migrations made easy',
    license='PostgreSQL License',
    url='https://github.com/yandex/pgmigrate/',
    author='Yandex LLC',
    author_email='opensource@yandex-team.ru',
    maintainer='Yandex LLC',
    maintainer_email='opensource@yandex-team.ru',
    zip_safe=False,
    platforms=['Linux', 'BSD', 'MacOS'],
    packages=['.'],
    entry_points={'console_scripts': [
        'pgmigrate = pgmigrate:_main',
    ]},
    install_requires=REQUIREMENTS,
)
