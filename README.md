# DevSHOK

DevSHOK is a tool for developers who develop applications which will be running in Kubernetes. Because every **DEV**eloper **S**hould **H**ave **O**wn **K**ubernetes!

It is supposed to be run on Linux and macOS (and was tested under them) but should also run everywhere where Bash, VirtualBox, curl and Kubernetes utls (kubectl, minikube) are available.

## Abilities

DevSHOK is able to:

* Prepare your machine for running local Kubernetes cluster:
  * On Linux: downloads kubectl, minikube, deploys cluster. No package installation due to zoo of package managers, but it will say if something is missing from your machine.
  * On macOS: complete preparation. This includes Brew installation if neccessary, installation of required tools (coreutils, VirtualBox from cask), cluster deployment.
* Cluster controlling - DevSHOK will start cluster if it stopped or create if it missing at all. This is the only cluster controlling actions for now.
* Services controlling:
  * Deployment based on Kubernetes config and own configuration with deployment function from application's configuration (if additional actions are required).
  * Undeployment based on undeployment function from application's configuration.
  * Getting service's IP address. It will return random address if more than one instance is launched.

## ToDo

* Complete cluster controlling (start/stop, undeployment, configuration).
* More services controlling options.
* Kubernetes configuration generation.
* DevSHOK configuration repositories.
* API versions.
* Dependencies checks (e.g. do we have configurations for dependencies or are they already deployed).
* (Maybe) Possibility to deploy applications remotely.

## History

This tool was developed after weeks of trying to setup Kubernetes cluster for development in "near production" mode - when all required services are started with at least 3 instances. Admins was lazy (or overloaded, who knows) but development shouldn't stop due to inability to test and develop. Here I (pztrn) enter and wrote a prototype in 4 hours.

After that a ToDo list was composed based on feedback from my coworkers and friends.

## Why shell (bash)

Because it should run everywhere without hassles after ``git clone``. And I decided to remember how to write complex scripts (or applications) in it.

## Installation

Clone this repo and execute ``devshok`` (Linux) or ``devshok-osx`` (macOS) with ``help`` option. If it shows help message - then you're ready to roll! If something is missing - your system should be automagically configured or DevSHOK will provide list of actions (or commands) to execute to get it running.

## Documentation

Complete documentation available in Markdown files in [doc directory](doc/index.md)