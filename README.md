# IP Spoofing Tester v1.4.7

## About the project

This image will run the CAIDA Spoofer (http://spoofer.caida.org/) to measure the Internet's
susceptibility to spoofed source address IP packets.

## Build

```
  docker build -t caida-spoofer-docker .
```

## Run

```
  docker run --network=host -it -v /etc/caida_spoofer/ssmtp/ssmtp.conf:/etc/ssmtp/ssmtp.conf -e EMAILADDRESS="user@domain.com" --rm caida-spoofer-docker:latest 
```

