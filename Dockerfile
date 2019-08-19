FROM alpine:3.10

RUN apk --no-cache add \
		bash \
		jq \
		python3 && \
	pip3 install \
		awscli===1.16.218

COPY new-task-definition.sh /
