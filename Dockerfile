#
# Copyright 2017 The Jaeger Authors
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
# in compliance with the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions and limitations under
# the License.
#

FROM eclipse-temurin:8 as builder

ENV APP_HOME /app/

COPY pom.xml $APP_HOME
COPY jaeger-spark-dependencies $APP_HOME/jaeger-spark-dependencies
COPY jaeger-spark-dependencies-cassandra $APP_HOME/jaeger-spark-dependencies-cassandra
COPY jaeger-spark-dependencies-elasticsearch $APP_HOME/jaeger-spark-dependencies-elasticsearch
COPY jaeger-spark-dependencies-common $APP_HOME/jaeger-spark-dependencies-common
COPY jaeger-spark-dependencies-test $APP_HOME/jaeger-spark-dependencies-test
COPY .mvn $APP_HOME/.mvn
COPY mvnw $APP_HOME

WORKDIR $APP_HOME
RUN ./mvnw package -Dlicense.skip=true -DskipTests=true
RUN rm -rf ~/.m2

FROM eclipse-temurin:8-jre
MAINTAINER Pavol Loffay <ploffay@redhat.com>
ENV APP_HOME /app/
COPY --from=builder $APP_HOME/jaeger-spark-dependencies/target/jaeger-spark-dependencies-0.0.2-SNAPSHOT.jar $APP_HOME/

WORKDIR $APP_HOME

COPY entrypoint.sh /

RUN chgrp root /etc/passwd && chmod g+rw /etc/passwd
USER 185

ENTRYPOINT ["/entrypoint.sh"]
CMD java ${JAVA_OPTS} -Dlog4j.configurationFile=classpath:log4j.properties -Dotel.service.name=jaeger-spark-dependencies -jar $APP_HOME/jaeger-spark-dependencies-0.0.2-SNAPSHOT.jar
