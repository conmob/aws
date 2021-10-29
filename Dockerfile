ARG AWS_VERSION="2.2.42"
ARG KUBECTL_VERSION="1.22.3"
ARG HELM_VERSION="3.7.1"
ARG TERRAFORM_VERSION="0.13.7"

FROM amazonlinux:2 AS installer

RUN yum update -y \
&& yum install -y curl unzip

ENV AWS_VERSION ${AWS_VERSION}
RUN curl -L https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_VERSION}.zip -o awscli.zip \
&& unzip awscli.zip \
&& ./aws/install --bin-dir /aws-cli-bin/

ENV KUBECTL_VERSION ${KUBECTL_VERSION}
RUN curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o kubectl \
&& mv kubectl /usr/local/bin/kubectl \
&& chmod +x /usr/local/bin/kubectl

ENV HELM_VERSION ${HELM_VERSION}
RUN curl -L https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.zip -o helm.zip \
&& unzip helm.zip \
&& mv linux-amd64/helm /usr/local/bin/helm \
&& chmod +x /usr/local/bin/helm

ENV TERRAFORM_VERSION ${TERRAFORM_VERSION}
RUN curl -L https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
&& unzip terraform.zip \
&& mv terraform /usr/local/bin/terraform \
&& chmod +x /usr/local/bin/terraform

FROM amazonlinux:2 AS runtime
COPY --from=installer /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=installer /aws-cli-bin/ /usr/local/bin/
COPY --from=installer /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --from=installer /usr/local/bin/helm /usr/local/bin/helm
COPY --from=installer /usr/local/bin/terraform /usr/local/bin/terraform

RUN yum update -y \
&& yum install -y curl git jq less groff \
&& yum clean all
