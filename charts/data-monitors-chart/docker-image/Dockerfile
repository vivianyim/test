# The docker image should be called "montecarlo-cli"
FROM python:3 as base

# Install the montecarlo cli
RUN pip install montecarlodata

RUN useradd -m -d /usr/montecarlo montecarlo

USER montecarlo

WORKDIR /usr/montecarlo

# This file must be present at the root dir of monitors configuration
COPY montecarlo.yml /usr/montecarlo