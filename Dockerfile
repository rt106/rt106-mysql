# Copyright (c) General Electric Company, 2017.  All rights reserved.

FROM mysql:5.7

ADD startup docker-entrypoint-initdb.d
